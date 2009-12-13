module Engine::DefaultBlocks
  def add_default_blocks
    add_default_init_blocks
    add_default_render_blocks
    add_default_update_blocks
  end

  private
  def add_default_init_blocks
    during_init do
      begin
        self.current_theme = themes(options[:theme])
      rescue Errors::ResourceNotFound # Don't worry if themes are unavailable, user may have removed them
      end
    end
    
    after_init { assume_controller(@options.delete(:controller), @options.delete(:action) || 'index') if options.key? :controller }
  end

  def add_default_render_blocks
    before_render do
      glClear(clear_on_render) if clear_on_render != 0
      glLoadIdentity()
    end

    during_render do
      if current_controller && current_controller.response.view
        current_controller.response.view.process
      end
    end
  end

  #FIXME: The SDL event loop can't be extended and processed from outside of the engine (for example, if the developer
  #wants to process Active events differently). Need to implement this.
  #
  def add_default_update_blocks
    before_update do |ticks, engine|
      while event = SDL::Event2.poll
#        #for some reason these aren't defined in my version of rubysdl. Hopefully that'll be fixed so I don't feel
#        #horrible for doing this:
#        app_mouse_focus = 1 # should be SDL::Event::APPMOUSEFOCUS
#        app_input_focus = 2 # should be SDL::Event::APPINPUTFOCUS
#        app_active      = 4 # should be SDL::Event::APPACTIVE

        case event
          when SDL::Event::Active then
#            if event.state & app_mouse_focus > 0 || event.state & app_input_focus > 0
#              if event.gain
#                #SDL::WM.grabInput(SDL::WM::GRAB_ON)
#              else
#                #SDL::WM.grabInput(SDL::WM::GRAB_OFF)
#              end
#            end
          when SDL::Event::Quit then stop!
          else
            begin
              event = Events::sdl_to_divinity(event)
              mouse.process_event(event) if mouse.respond_to_event? event
              keyboard.process_event(event) if keyboard.respond_to_event? event
            rescue Errors::EventNotRecognized
            end
        end
      end unless dry_run?
    end

    during_update do |ticks, engine|
      @framecount = @framecount.to_i + 1
      @seconds_passed = @seconds_passed.to_i + ticks
      if @seconds_passed > 1000 # update framerate every 1 second
        @framerate = @framecount
        @framecount = 0
        @seconds_passed = 0
      end

      if current_controller
        current_controller.request.parameters[:delta] = ticks
        if current_controller.respond_to? :update
          # By saving the overhead of calling #process for an action as frequently-called as #update, we can
          # save 500 frames per second (on my box)! I'm not seeing any side effects, either, so far.
          #current_controller.send(:erase_results)
          #current_controller.update if current_controller.respond_to? :update
          #current_controller.send(:render, :action => 'update') ## this is what's killing the FPS
          #current_controller.process(:update)
          current_controller.process(:update, :render => false, :models => false)
        end
      end
    end
  end
end
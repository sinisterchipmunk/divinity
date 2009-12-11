module Engine::DefaultUpdateBlock
  #TODO: The event loop can't be extended and processed from outside of the engine (for example, if the developer
  #wants to process Active events differently). Need to implement this.
  #
  def add_default_update_block
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
      if @controller
        @controller.request.parameters[:delta] = ticks
        if @controller.respond_to? :update
          @controller.process(:update)
        end
      end
    end
  end
end
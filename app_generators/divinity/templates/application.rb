require 'config/boot'

engine = DivinityEngine.new(:width => 800,               # 800 pixels wide
                            :height => 600,              # 600 pixels high
                            :fullscreen => false,        # Run as a window
                            :controller => '<%=module_name.underscore%>'   # Start at <%=module_name%>Controller
                           )

engine.go!                                               # start the engine

require 'config/boot'

engine = DivinityEngine.new(:width => 800,               # 800 pixels wide
                            :height => 600,              # 600 pixels high
                            :fullscreen => false,        # Run as a window
                            :controller => 'application' # Start at Engines::ApplicationController
                           )

engine.go!                                               # start the engine

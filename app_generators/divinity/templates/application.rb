require 'config/boot'

engine = DivinityEngine.new(:width => 800, :height => 600, :fullscreen => false, :controller => 'application')
engine.go! # start the engine

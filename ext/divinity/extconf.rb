require 'mkmf'

dir_config('divinity')
have_library 'opengl32', 'main'
create_makefile('divinity')

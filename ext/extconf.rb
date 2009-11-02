require 'mkmf'

extension_name = 'divinity_ext'
dir_config(extension_name)
have_library 'opengl32', 'main'
create_makefile(extension_name)

# Generated by jeweler
# DO NOT EDIT THIS FILE DIRECTLY
# Instead, edit Jeweler::Tasks in rakefile, and run the gemspec command
# -*- encoding: utf-8 -*-

Gem::Specification.new do |s|
  s.name = %q{divinity}
  s.version = "0.1.0"

  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
  s.authors = ["Colin MacKenzie IV (sinisterchipmunk)"]
  s.date = %q{2010-01-07}
  s.default_executable = %q{divinity}
  s.description = %q{A new kind of game engine}
  s.email = %q{sinisterchipmunk@gmail.com}
  s.executables = ["divinity"]
  s.extensions = ["ext/divinity/extconf.rb"]
  s.extra_rdoc_files = [
    "LICENSE",
     "README.rdoc"
  ]
  s.files = [
    ".gitignore",
     "LICENSE",
     "README.rdoc",
     "TODO.rdoc",
     "VERSION",
     "app_generators/divinity/USAGE",
     "app_generators/divinity/divinity_generator.rb",
     "app_generators/divinity/templates/README",
     "app_generators/divinity/templates/Rakefile",
     "app_generators/divinity/templates/app/controllers/application_controller.rb",
     "app_generators/divinity/templates/app/controllers/controller.rb",
     "app_generators/divinity/templates/app/helpers/application_helper.rb",
     "app_generators/divinity/templates/app/helpers/helper.rb",
     "app_generators/divinity/templates/app/views/application/_framerate.rb",
     "app_generators/divinity/templates/app/views/application/index.rb",
     "app_generators/divinity/templates/application.rb",
     "app_generators/divinity/templates/config/boot.rb",
     "app_generators/divinity/templates/config/environment.rb",
     "app_generators/divinity/templates/config/environments/development.rb",
     "app_generators/divinity/templates/config/environments/production.rb",
     "app_generators/divinity/templates/config/environments/test.rb",
     "app_generators/divinity/templates/config/initializers/backtrace_silencers.rb",
     "app_generators/divinity/templates/config/initializers/inflections.rb",
     "app_generators/divinity/templates/config/locales/en.yml",
     "app_generators/divinity/templates/doc/README_FOR_APP",
     "app_generators/divinity/templates/log/development.log",
     "app_generators/divinity/templates/log/production.log",
     "app_generators/divinity/templates/log/test.log",
     "app_generators/divinity/templates/resources/resource_map.yml",
     "app_generators/divinity/templates/script/console",
     "app_generators/divinity/templates/script/destroy",
     "app_generators/divinity/templates/script/generate",
     "app_generators/divinity/templates/script/plugin",
     "app_generators/divinity/templates/script/winscript.cmd",
     "app_generators/divinity/templates/test/functional/controller.rb",
     "app_generators/divinity/templates/test/test_helper.rb",
     "app_generators/divinity/templates/winapp.cmd",
     "bin/divinity",
     "builtin/app/controllers/components/button_controller.rb",
     "builtin/app/controllers/components/component_controller.rb",
     "builtin/app/controllers/components/panel_controller.rb",
     "builtin/app/helpers/components/button_helper.rb",
     "builtin/app/helpers/components/component_helper.rb",
     "builtin/app/helpers/components/panel_helper.rb",
     "builtin/app/models/actor.rb",
     "builtin/app/models/components/button.rb",
     "builtin/app/models/components/panel.rb",
     "builtin/app/models/events.rb",
     "builtin/app/models/events/generic.rb",
     "builtin/app/models/events/input_event.rb",
     "builtin/app/models/events/interface_events.rb",
     "builtin/app/models/events/interface_events/controller_created_event.rb",
     "builtin/app/models/events/interface_events/focus_event.rb",
     "builtin/app/models/events/interface_events/interface_assumed.rb",
     "builtin/app/models/events/interface_events/redirected.rb",
     "builtin/app/models/events/keyboard_events.rb",
     "builtin/app/models/events/keyboard_events/key_event.rb",
     "builtin/app/models/events/keyboard_events/key_pressed.rb",
     "builtin/app/models/events/keyboard_events/key_released.rb",
     "builtin/app/models/events/mouse_events.rb",
     "builtin/app/models/events/mouse_events/mouse_button_event.rb",
     "builtin/app/models/events/mouse_events/mouse_event.rb",
     "builtin/app/models/events/mouse_events/mouse_moved.rb",
     "builtin/app/models/events/mouse_events/mouse_pressed.rb",
     "builtin/app/models/events/mouse_events/mouse_released.rb",
     "builtin/app/models/events/sdl_events.txt",
     "builtin/app/models/theme.rb",
     "builtin/app/views/components/button/index.rb",
     "builtin/app/views/components/panel/index.rb",
     "builtin/lib/theme/effects/button_effect.rb",
     "builtin/lib/theme/effects/effect.rb",
     "builtin/lib/theme/theme_type.rb",
     "builtin/resources/actors/player.rb",
     "builtin/resources/resource_map.yml",
     "builtin/resources/themes/default.rb",
     "divinity.gemspec",
     "divinity_generators/content_module/USAGE",
     "divinity_generators/content_module/content_module_generator.rb",
     "divinity_generators/content_module/templates/actors/joe.rb",
     "divinity_generators/content_module/templates/resource_map.yml",
     "divinity_generators/controller/USAGE",
     "divinity_generators/controller/controller_generator.rb",
     "divinity_generators/controller/templates/_framerate.rb",
     "divinity_generators/controller/templates/controller.rb",
     "divinity_generators/controller/templates/functional_test.rb",
     "divinity_generators/controller/templates/helper.rb",
     "divinity_generators/controller/templates/view.rb",
     "divinity_generators/interface/USAGE",
     "divinity_generators/interface/interface_generator.rb",
     "divinity_generators/interface/templates/app/controller.rb",
     "divinity_generators/interface/templates/app/helper.rb",
     "divinity_generators/interface/templates/app/view.rb",
     "divinity_generators/interface/templates/test/functional.rb",
     "divinity_generators/model/USAGE",
     "divinity_generators/model/model_generator.rb",
     "divinity_generators/model/templates/fixture.yml",
     "divinity_generators/model/templates/model.rb",
     "divinity_generators/model/templates/unit_test.rb",
     "ext/divinity/Makefile",
     "ext/divinity/array.c",
     "ext/divinity/divinity.c",
     "ext/divinity/divinity.h",
     "ext/divinity/divinity_macros.h",
     "ext/divinity/extconf.rb",
     "ext/divinity/frustum.c",
     "ext/divinity/mkmf.log",
     "ext/divinity/octree.c",
     "ext/divinity/octree_object_descriptor.c",
     "ext/divinity/open_gl.c",
     "ext/divinity/planes_and_vertices.c",
     "ext/divinity/render_helper.c",
     "ext/divinity/ruby.h",
     "ext/divinity/vector3d.c",
     "lib/code_statistics.rb",
     "lib/dependencies.rb",
     "lib/dependencies/geometry.rb",
     "lib/dependencies/helpers.rb",
     "lib/dependencies/open_gl.rb",
     "lib/devices/input_device.rb",
     "lib/devices/keyboard.rb",
     "lib/devices/keyboard/modifiers.rb",
     "lib/devices/mouse.rb",
     "lib/divinity.rb",
     "lib/divinity/backtrace_cleaner.rb",
     "lib/divinity/configuration.rb",
     "lib/divinity/content_module.rb",
     "lib/divinity/content_module/loader.rb",
     "lib/divinity/gem_dependency.rb",
     "lib/divinity/gem_plugin.rb",
     "lib/divinity/initializer.rb",
     "lib/divinity/ordered_options.rb",
     "lib/divinity/plugin.rb",
     "lib/divinity/plugin/gem_locator.rb",
     "lib/divinity/plugin/loader.rb",
     "lib/divinity/plugin/locator.rb",
     "lib/divinity/vendor_gem_source_index.rb",
     "lib/divinity/version.rb",
     "lib/divinity_engine.rb",
     "lib/divinity_test_help.rb",
     "lib/engine/cache.rb",
     "lib/engine/controller.rb",
     "lib/engine/controller/base.rb",
     "lib/engine/controller/class_methods.rb",
     "lib/engine/controller/engine_controller.rb",
     "lib/engine/controller/event_dispatching.rb",
     "lib/engine/controller/helpers.rb",
     "lib/engine/controller/input_device_proxy.rb",
     "lib/engine/controller/interface_controller.rb",
     "lib/engine/controller/keyboard_proxy.rb",
     "lib/engine/controller/mouse_proxy.rb",
     "lib/engine/controller/request.rb",
     "lib/engine/controller/response.rb",
     "lib/engine/controller/routing.rb",
     "lib/engine/controller/view_paths.rb",
     "lib/engine/default_blocks.rb",
     "lib/engine/delegation.rb",
     "lib/engine/model/base.rb",
     "lib/engine/resources.rb",
     "lib/engine/view.rb",
     "lib/engine/view/base.rb",
     "lib/engine/view/engine_view.rb",
     "lib/errors.rb",
     "lib/errors/event_errors.rb",
     "lib/errors/file_missing.rb",
     "lib/errors/resource_mapping.rb",
     "lib/errors/resource_not_found.rb",
     "lib/extensions/array.rb",
     "lib/extensions/bytes.rb",
     "lib/extensions/fixnum.rb",
     "lib/extensions/magick.rb",
     "lib/extensions/magick/image.rb",
     "lib/extensions/magick/image_list.rb",
     "lib/extensions/magick_extensions.rb",
     "lib/extensions/matrix.rb",
     "lib/extensions/numeric.rb",
     "lib/extensions/object.rb",
     "lib/extensions/string.rb",
     "lib/geometry/dimension.rb",
     "lib/geometry/plane.rb",
     "lib/geometry/point.rb",
     "lib/geometry/rectangle.rb",
     "lib/geometry/vector3d.rb",
     "lib/helpers/attribute_helper.rb",
     "lib/helpers/component_helper.rb",
     "lib/helpers/content_helper.rb",
     "lib/helpers/event_listening_helper.rb",
     "lib/helpers/render_helper.rb",
     "lib/interface/layouts/alignment.rb",
     "lib/interface/layouts/border_layout.rb",
     "lib/interface/layouts/flow_layout.rb",
     "lib/interface/layouts/grid_layout.rb",
     "lib/interface/layouts/layout.rb",
     "lib/math/dice.rb",
     "lib/math/die.rb",
     "lib/open_gl/camera.rb",
     "lib/open_gl/display_list.rb",
     "lib/open_gl/frustum.rb",
     "lib/open_gl/octree.rb",
     "lib/physics/gravity/gravitational_field.rb",
     "lib/physics/gravity/gravity_source.rb",
     "lib/requires.rb",
     "lib/resource/base.rb",
     "lib/resource/class_methods.rb",
     "lib/resource/image.rb",
     "lib/resource/world/object.rb",
     "lib/resource/world/scene.rb",
     "lib/resource/world/scenes/height_map.rb",
     "lib/tasks/divinity.rb",
     "lib/tasks/documentation.rake",
     "lib/tasks/framework.rake",
     "lib/tasks/gems.rake",
     "lib/tasks/log.rake",
     "lib/tasks/misc.rake",
     "lib/tasks/statistics.rake",
     "lib/tasks/testing.rake",
     "lib/tasks/tmp.rake",
     "lib/test/engine/test_case.rb",
     "lib/test/unit/test_case.rb",
     "lib/textures/font.rb",
     "lib/textures/texture.rb",
     "lib/textures/texture_generator.rb",
     "rakefile",
     "script/console",
     "script/console.cmd",
     "script/destroy",
     "script/destroy.cmd",
     "script/generate",
     "script/generate.cmd",
     "tasks/dev.rake",
     "tasks/docs.rake",
     "tasks/jeweler.rake",
     "tasks/tests.rake",
     "test/app/README",
     "test/app/Rakefile",
     "test/app/app.cmd",
     "test/app/app.rb",
     "test/app/app/controllers/another_controller.rb",
     "test/app/app/controllers/app_controller.rb",
     "test/app/app/controllers/application_controller.rb",
     "test/app/app/controllers/interfaces/main_menu_controller.rb",
     "test/app/app/controllers/t_controller.rb",
     "test/app/app/helpers/another_helper.rb",
     "test/app/app/helpers/app_helper.rb",
     "test/app/app/helpers/application_helper.rb",
     "test/app/app/helpers/interfaces/main_menu_helper.rb",
     "test/app/app/helpers/t_helper.rb",
     "test/app/app/views/another/_framerate.rb",
     "test/app/app/views/another/test.rb",
     "test/app/app/views/app/_framerate.rb",
     "test/app/app/views/app/index.rb",
     "test/app/app/views/interfaces/main_menu/index.rb",
     "test/app/app/views/t/_framerate.rb",
     "test/app/app/views/t/index.rb",
     "test/app/config/boot.rb",
     "test/app/config/environment.rb",
     "test/app/config/environments/development.rb",
     "test/app/config/environments/production.rb",
     "test/app/config/environments/test.rb",
     "test/app/config/initializers/backtrace_silencers.rb",
     "test/app/config/initializers/inflections.rb",
     "test/app/config/locales/en.yml",
     "test/app/doc/README_FOR_APP",
     "test/app/log/development.log",
     "test/app/log/production.log",
     "test/app/log/test.log",
     "test/app/script/console",
     "test/app/script/console.cmd",
     "test/app/script/destroy",
     "test/app/script/destroy.cmd",
     "test/app/script/generate",
     "test/app/script/generate.cmd",
     "test/app/script/plugin",
     "test/app/script/plugin.cmd",
     "test/app/test/functional/another_test.rb",
     "test/app/test/functional/t_test.rb",
     "test/app/test/test_helper.rb",
     "test/app/tmp/cache/font/8237755daf402bfda5bf8fe742045b19.png",
     "test/app/vendor/mods/test_mod/resource_map.yml",
     "test/app/vendor/plugins/mytest/init.rb",
     "test/camera_test.rb",
     "test/divinity.log",
     "test/engine/engine_test_case_test.rb",
     "test/frustum_test.rb",
     "test/octree_test.rb",
     "test/test_content_module_generator.rb",
     "test/test_controller_generator.rb",
     "test/test_divinity.rb",
     "test/test_generator_helper.rb",
     "test/test_helper.rb",
     "test/test_interface_generator.rb",
     "test/test_model_generator.rb",
     "test/test_resource_generator.rb",
     "test/unit/extensions/array_test.rb",
     "test/unit/extensions/fixnum_test.rb",
     "test/unit/geometry/vector3d_test.rb",
     "test/unit/geometry/vertex3d_test.rb",
     "test/unit/models/events_test.rb"
  ]
  s.homepage = %q{http://github.com/sinisterchipmunk/divinity}
  s.rdoc_options = ["--charset=UTF-8"]
  s.require_paths = ["lib"]
  s.rubygems_version = %q{1.3.5}
  s.summary = %q{A new kind of game engine}
  s.test_files = [
    "test/app/app/controllers/another_controller.rb",
     "test/app/app/controllers/application_controller.rb",
     "test/app/app/controllers/app_controller.rb",
     "test/app/app/controllers/interfaces/main_menu_controller.rb",
     "test/app/app/controllers/t_controller.rb",
     "test/app/app/helpers/another_helper.rb",
     "test/app/app/helpers/application_helper.rb",
     "test/app/app/helpers/app_helper.rb",
     "test/app/app/helpers/interfaces/main_menu_helper.rb",
     "test/app/app/helpers/t_helper.rb",
     "test/app/app/views/another/test.rb",
     "test/app/app/views/another/_framerate.rb",
     "test/app/app/views/app/index.rb",
     "test/app/app/views/app/_framerate.rb",
     "test/app/app/views/interfaces/main_menu/index.rb",
     "test/app/app/views/t/index.rb",
     "test/app/app/views/t/_framerate.rb",
     "test/app/app.rb",
     "test/app/config/boot.rb",
     "test/app/config/environment.rb",
     "test/app/config/environments/development.rb",
     "test/app/config/environments/production.rb",
     "test/app/config/environments/test.rb",
     "test/app/config/initializers/backtrace_silencers.rb",
     "test/app/config/initializers/inflections.rb",
     "test/app/test/functional/another_test.rb",
     "test/app/test/functional/t_test.rb",
     "test/app/test/test_helper.rb",
     "test/app/vendor/plugins/mytest/init.rb",
     "test/camera_test.rb",
     "test/engine/engine_test_case_test.rb",
     "test/frustum_test.rb",
     "test/octree_test.rb",
     "test/test_content_module_generator.rb",
     "test/test_controller_generator.rb",
     "test/test_divinity.rb",
     "test/test_generator_helper.rb",
     "test/test_helper.rb",
     "test/test_interface_generator.rb",
     "test/test_model_generator.rb",
     "test/test_resource_generator.rb",
     "test/unit/extensions/array_test.rb",
     "test/unit/extensions/fixnum_test.rb",
     "test/unit/geometry/vector3d_test.rb",
     "test/unit/geometry/vertex3d_test.rb",
     "test/unit/models/events_test.rb"
  ]

  if s.respond_to? :specification_version then
    current_version = Gem::Specification::CURRENT_SPECIFICATION_VERSION
    s.specification_version = 3

    if Gem::Version.new(Gem::RubyGemsVersion) >= Gem::Version.new('1.2.0') then
      s.add_development_dependency(%q<shoulda>, [">= 0"])
      s.add_development_dependency(%q<rake-compiler>, [">= 0.7.0"])
      s.add_runtime_dependency(%q<activesupport>, [">= 2.3.4"])
      s.add_runtime_dependency(%q<ruby-opengl>, [">= 0.60.1"])
      s.add_runtime_dependency(%q<rmagick>, [">= 2.12.0"])
      s.add_runtime_dependency(%q<log4r>, [">= 1.1.2"])
      s.add_runtime_dependency(%q<rubigen>, [">= 1.5.2"])
      s.add_runtime_dependency(%q<ruby-sdl-ffi>, [">= 0.2"])
    else
      s.add_dependency(%q<shoulda>, [">= 0"])
      s.add_dependency(%q<rake-compiler>, [">= 0.7.0"])
      s.add_dependency(%q<activesupport>, [">= 2.3.4"])
      s.add_dependency(%q<ruby-opengl>, [">= 0.60.1"])
      s.add_dependency(%q<rmagick>, [">= 2.12.0"])
      s.add_dependency(%q<log4r>, [">= 1.1.2"])
      s.add_dependency(%q<rubigen>, [">= 1.5.2"])
      s.add_dependency(%q<ruby-sdl-ffi>, [">= 0.2"])
    end
  else
    s.add_dependency(%q<shoulda>, [">= 0"])
    s.add_dependency(%q<rake-compiler>, [">= 0.7.0"])
    s.add_dependency(%q<activesupport>, [">= 2.3.4"])
    s.add_dependency(%q<ruby-opengl>, [">= 0.60.1"])
    s.add_dependency(%q<rmagick>, [">= 2.12.0"])
    s.add_dependency(%q<log4r>, [">= 1.1.2"])
    s.add_dependency(%q<rubigen>, [">= 1.5.2"])
    s.add_dependency(%q<ruby-sdl-ffi>, [">= 0.2"])
  end
end


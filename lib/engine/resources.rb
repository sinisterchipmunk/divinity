module Engine::Resources
    # Iterates through each active ContentModule and searches its base path for the specified file.
  # As a last resort, looks for the file in "data/#{filename}".
  # The last ContentModule loaded has the highest priority and will be searched first.
  def find_file(*filenames)
    locations = [ ]
    filenames.flatten!
    filenames.each do |filename|
      return filename if File.file? filename
      locations << filename
      unless filename =~ /^([\/\\]|.:[\/\\])/ # don't treat absolute paths as relative ones
        # Search the user-defined overrides first
        fi = File.join(DIVINITY_ROOT, 'data/override', filename)
        return fi if File.file? fi
        locations << fi

        # Then search the divinity engine core
        fi = File.join(DIVINITY_FRAMEWORK_ROOT, "builtin", filename)
        return fi if File.file? fi
        locations << fi


#        load_content! unless @content_modules
#        # Order is reversed because we want the LAST plugin loaded to override any preceding it
#        @content_modules.reverse.each do |cm|
#          fi = File.join(cm.base_path, filename)
#          return fi if File.file? fi
#          locations << fi
#        end
      end

      # See if it turns up if we stick an extension on the end
      filenames << "#{filename}.rb" unless filename =~ /\.rb$/
    end

    sentence = locations.to_sentence
    raise Errors::FileMissing, "Could not find file! Looked in #{sentence}"
  end

  # Takes a pattern or series of patterns and searches for their occurrance in each registered ContentModule
  def glob_files(*paths)
    load_content! unless @content_modules
    matches = []
    paths.flatten.each do |path|
      @content_modules.reverse.each do |cm|
        matches += Dir.glob(File.join(cm.base_path, path))
      end
    end
    matches.uniq
  end
end
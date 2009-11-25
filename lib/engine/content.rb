module Engine::Content
  { :themes => Interface::Theme, :images => Resources::Image, 
    :actors => World::Actor, :languages => World::Character::Language,
    :races  => World::Character::Race, :character_classes => World::Character::CharacterClass }.each do |plural, klass|
    class_name = klass.name
    singular = plural.to_s.singularize

    line = __LINE__ + 2
    code = <<-end_code
      def #{singular}(id, *args, &block)
        r = self.#{plural}[id]
        if r.nil? then r = self.#{plural}[id] = #{class_name}.new(id, self, *args)
        elsif args.length > 0 then r = r.with_args(*args)
        end
        r.instance_eval(&block) if block_given?
        r
      end

      def #{plural}
        unless @#{plural}
          @#{plural} = HashWithIndifferentAccess.new
          content_modules.each do |mod|
            @#{plural}.merge!(mod.#{plural})
          end
        end
        @#{plural}
      end
    end_code
    eval code, binding, __FILE__, line
  end
end

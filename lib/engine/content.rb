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

#  generic_content_loader :themes => Interface::Theme, :actors => World::Actor, :languages => World::Character::Language,
#                         :races  => World::Character::Race, :character_classes => World::Character::CharacterClass


=begin
  def self.included(base)
    base.load_content_for :themes,    Interface::Theme
    base.load_content_for :actors,    World::Actor
    base.load_content_for :languages, World::Character::Language
    base.load_content_for :races,     World::Character::Race
    base.load_content_for :character_classes,   World::Character::CharacterClass
  end


  class methods:


  def load_content_for(name, class_name)
    class_name = class_name.name unless class_name.kind_of? String
    class_name = class_name.camelize

    name = name.to_s.singularize
    plural = name.pluralize

    line = __LINE__ + 2
    code = <<-end_code
    def #{name}(id, &block)
      r = self.#{plural}[id]
      r = self.#{plural}[id] = #{class_name}.new(id, self, &block) if r.nil?
      r.instance_eval &block if block_given?
      r
    end

    def #{plural}
      if @#{plural}.nil?
        # Load them
        @#{plural} ||= HashWithIndifferentAccess.new
        Dir.glob("modules/*/#{plural}/**/*.rb").each do |fi|
          next if File.directory? fi or fi =~ /\.svn/
          eval File.read(fi), binding, fi, 1
        end
      end
      @#{plural}
    end
    end_code

    eval code, self.class_eval("binding"), __FILE__, line
  end
=end
end

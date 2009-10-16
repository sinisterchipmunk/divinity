module Engine::Content
  def self.included(base)
    base.load_content_for :themes,    Interface::Theme
    base.load_content_for :actors,    World::Actor
    base.load_content_for :languages, World::Character::Language
    base.load_content_for :races,     World::Character::Race
    base.load_content_for :character_classes,   World::Character::CharacterClass
  end
end

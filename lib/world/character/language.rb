class World::Character::Language < Resources::Content
  random_access_attr :alphabet, :secret

  def revert_to_defaults!
    alphabet id
    secret false
  end

  def secret?
    @secret
  end
end

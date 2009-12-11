module Engine::View
  class ViewError < StandardError
  end

  class MissingViewError < ViewError
  end

  class InterfaceError < ViewError
  end
end

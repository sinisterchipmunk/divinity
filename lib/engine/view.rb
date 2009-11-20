module Engine::View
  class ViewError < StandardError
  end

  class MissingInterfaceError < ViewError
  end

  class InterfaceError < ViewError
  end
end

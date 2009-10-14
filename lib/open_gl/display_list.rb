class OpenGL::DisplayList
  include Helpers::RenderHelper

  # If deferred == true, list generation will be deferred until the
  # first time #call is executed. Otherwise, it will be run immediately.
  def initialize(how_many = 1, deferred = true, &block)
    @list_base = -1
    @how_many = how_many
    @block = block
    build &@block unless deferred
  end

  def call(*lists)
    build &@block if @list_base == -1

    glPushAttrib(GL_LIST_BIT)
      glListBase @list_base
      if method(:glCallLists).arity == 1
        lists << [0] if lists.length == 0
        glCallLists *lists
      else # this changed with ruby-opengl 0.6
        glCallLists GL_BYTE, *lists
      end
    glPopAttrib
  end

  def rebuild!(how_many = nil, deferred = true, &block)
    how_many ||= @how_many
    teardown!
    @how_many = how_many
    @block = block if block_given?
    build &@block unless deferred
  end

  # This is called primarily when a component is removed from a container. It's only because I can't
  # find whether lists, textures, etc are deleted automatically by the Ruby garbage collector. Better safe than sorry.
  def teardown!
    if @list_base != -1
      glDeleteLists(@list_base, @how_many)
      @list_base = -1
    end
  end

  private
  def build
    teardown!
    @list_base = glGenLists(@how_many)
    @how_many.times do |i|
      glNewList(@list_base+i, GL_COMPILE)
        yield i
      glEndList
    end
  end
end

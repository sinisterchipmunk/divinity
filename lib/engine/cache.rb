class Engine::Cache
  attr_reader :hash
  delegate :[], :[]=, :to => :hash

  def initialize
    @hash = {}
  end

  def read_or_write(key, default_value)
    read(key) || write(key, default_value)
  end

  def read(key) hash[key]; end
  def write(key, value) hash[key] = value; end

  private :hash
end

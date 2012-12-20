require 'pstore'

class StateFile

  def initialize(path)
    @exists = File.exist?(path)
    @store = PStore.new(path)
    @store.ultra_safe = true
  end

  # Public: Has this state file been created?
  # Returns boolean:
  #    false if the statefile has not been written to yet
  #    true if it has been previously written to
  def exist?
    @exists
  end

  # Public: Read the value for a given ID
  #
  # Returns the previously set value or 
  #         nil if the key is unknown
  def read(id)
    @store.transaction do
      @store[id]
    end
  end

  # Public: Write a value for a given ID
  #
  # Arguments:
  #    id - the key in key/value
  #    value - the value in key/value
  #
  def write(id, value)
    @exists = true
    @store.transaction do
      @store[id] = value
    end
  end
end
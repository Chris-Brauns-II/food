module Core
  class Stream
    IdNameNotSymbolError = Class.new(StandardError)
    IdNameNotSetError = Class.new(StandardError)
    IdNameAlreadySetError = Class.new(StandardError)

    def self.id_name(name)
      raise IdNameNotSymbolError unless name.is_a?(Symbol)
      raise IdNameAlreadySetError if @id_name.present?

      @id_name = name

      define_method(name) do
        id
      end
    end

    def self.id
      raise IdNameNotSetError if @id_name.blank?

      @id_name
    end

    def initialize(**kwarg)
      value = kwarg[self.class.id]
      raise ArgumentError, "Expected keyword argument #{self.class.id} for #{self.class.name}" unless kwarg.key?(self.class.id)

      @id = value
    end

    def to_s
      "#<#{self.class.name} #{self.class.id}: #{id}>"
    end

    def ==(other)
      self.class == other.class && id == other.id
    end

    def serialize
      id
    end

    def self.deserialize(hash)
      new(**{ id => hash })
    end

    attr_reader :id
  end
end

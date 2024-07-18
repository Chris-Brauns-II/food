module Core
  class SubClass
    def self.Of(klass) # rubocop:disable Naming/MethodName
      new(klass)
    end

    def ===(other)
      other <= @klass
    end

    private

    def initialize(klass)
      @klass = klass
    end
  end
end

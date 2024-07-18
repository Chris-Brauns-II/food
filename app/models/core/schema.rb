module Core
  class Schema
    module Status
      ALL = [
        ACTIVE = "active".freeze,
        DEPRECATED = "deprecated".freeze,
        INACTIVE = "inactive".freeze,
        DESTROYED = "destroyed".freeze
      ].freeze
    end

    include(ValueSemantics.for_attributes do
      data
      metadata
      type Either(Core::COMMAND, Core::EVENT)
      version Integer
      status Either(*Status::ALL)
      message_type Either(*MessageTypes::ALL)
      stream SubClass.Of(Stream)
    end)

    def serialize
      {
        version:,
        message_type:
      }
    end

    def self.deserialize(hash)
      MessageService.get_schema(message_type: hash[:message_type], version: hash[:version])
    end

    def self.active(data:, metadata:, message_type:, version:, stream:, type:) # rubocop:disable Metrics/ParameterLists
      schema = new(data:, metadata:, message_type:, version:, stream:, type:, status: Status::ACTIVE)
      MessageService.register(schema:)
      schema
    end

    def self.deprecated(data:, metadata:, message_type:, version:, stream:, type:) # rubocop:disable Metrics/ParameterLists
      schema = new(data:, metadata:, message_type:, version:, stream:, type:, status: Status::DEPRECATED)
      MessageService.register(schema:)
      schema
    end

    def self.inactive(data:, metadata:, message_type:, version:, stream:, type:) # rubocop:disable Metrics/ParameterLists
      schema = new(data:, metadata:, message_type:, version:, stream:, type:, status: Status::INACTIVE)
      MessageService.register(schema:)
      schema
    end

    def self.destroy!(data:, metadata:, message_type:, version:, stream:, type:) # rubocop:disable Metrics/ParameterLists
      schema = new(data:, metadata:, message_type:, version:, stream:, type:, status: Status::DESTROYED)
      MessageService.register(schema:)
      schema
    end

    def all_messages
      MessageService.all_messages(self)
    end

    def active?
      status == Status::ACTIVE
    end

    def deprecated?
      status == Status::DEPRECATED
    end

    def inactive?
      status == Status::INACTIVE
    end

    def destroyed?
      status == Status::DESTROYED
    end

    def to_s
      "#<Core::Schema message_type: #{message_type}, version: #{version}>"
    end
  end
end

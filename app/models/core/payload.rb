module Core
  module Payload
    CannotCreateDefaultError = Class.new(StandardError)

    def schema(&)
      include(ValueSemantics.for_attributes(&))
      include Core::Payload
    end

    delegate :to_h, to: :serialize

    def generate_default
      new(**generate_default_attributes)
    end

    def generate_default_attributes
      raise CannotCreateDefaultError if Rails.env.production?

      attribute_hash = {}
      value_semantics.attributes.each do |attr|
        attribute_hash[attr.name] = default_value(attr.validator)
      end

      attribute_hash
    end

    def serialize
      hash = {}

      self.class.value_semantics.attributes.each do |attr|
        value = to_serialized_value(send(attr.name))
        hash[attr.name] = value
      end

      hash
    end

    def deserialize(hash)
      deserialized_hash = {}

      value_semantics.attributes.each do |attr|
        # If a child is also a payload call from_hash as well verse taking the straight value
        next unless hash.key?(attr.name)

        value = from_serialized_value(attr.validator, hash[attr.name])
        deserialized_hash[attr.name] = value
      end

      new(**deserialized_hash)
    end

    private

    def to_serialized_value(value)
      if value.is_a?(Array)
        if value.first.respond_to?(:serialize)
          value.map(&:serialize)
        elsif value.first.respond_to?(:to_h)
          value.map(&:to_h)
        else
          value
        end
      elsif value.nil?
        nil
      elsif value.respond_to?(:serialize)
        value.serialize
      elsif value.respond_to?(:to_h)
        value.to_h
      else
        value
      end
    end

    def from_serialized_value(validator, value)
      if validator.is_a?(ValueSemantics::ArrayOf)
        value.map { |v| from_serialized_value(validator.element_validator, v) }
      elsif validator.respond_to?(:deserialize)
        validator.deserialize(value)
      else
        value
      end
    end

    def default_value(validator)
      case validator
      when ValueSemantics::ArrayOf
        [default_value(validator.element_validator)]
      when ValueSemantics::HashOf
        { default_value(validator.key_validator) => default_value(validator.value_validator) }
      when ValueSemantics::Either
        default_value(validator.subvalidators[0])
      else
        if validator.respond_to?(:generate_default)
          validator.generate_default
        elsif validator == String
          "Example"
        elsif validator == Uuid
          SecureRandom.uuid
        elsif validator == ValueSemantics::Bool
          false
        elsif validator == Hash
          {}
        elsif validator == Array
          []
        elsif validator.is_a?(Range)
          validator.begin || validator.end
        elsif validator == Date
          Date.new(2021, 1, 1)
        elsif validator == ActiveSupport::TimeWithZone
          Time.zone.local(2021, 1, 1)
        else
          validator
        end
      end
    end
  end
end

module Attributes
  class AttributesReactor < MessageReactor
    def create(attribute_id:, name:, description:, set:, default:)
      message_service.create!(
        schema: Events::AttributeCreated::V1,
        attribute_id:,
        data: {
          name:,
          description:,
          set:,
          default:
        }
      )
    end

    def update(attribute_id:, name:, description:, set:, default:)
      message_service.create!(
        schema: Events::AttributeUpdated::V1,
        attribute_id:,
        data: {
          name:,
          description:,
          set:,
          default:
        }
      )
    end

    def destroy(attribute_id:)
      message_service.create!(
        schema: Events::AttributeDeleted::V1,
        attribute_id:,
        data: Core::Nothing
      )
    end
  end
end

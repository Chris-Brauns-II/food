module Admin
  class AttributesController < AdminController
    include MessageEmitter

    def index
      render json: Attributes::AttributesQuery.all
    end

    def create
      attribute_id = SecureRandom.uuid
      name = params[:name]
      set = params[:set]
      default = params[:default]
      description = params[:description]

      with_message_service do
        Attributes::AttributesReactor.new(message_service:).create(
          attribute_id:,
          name:,
          description:,
          set:,
          default:
        )
      end

      head :created
    end

    def update
      attribute_id = params[:id]
      name = params[:name]
      set = params[:set]
      default = params[:default]
      description = params[:description]

      with_message_service do
        Attributes::AttributesReactor.new(message_service:).update(
          attribute_id:,
          name:,
          description:,
          set:,
          default:
        )
      end
    end

    def destroy
      attribute_id = params[:id]

      with_message_service do
        Attributes::AttributesReactor.new(message_service:).destroy(
          attribute_id:
        )
      end
    end
  end
end

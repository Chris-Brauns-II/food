module Admin
  class JobAttributesController < AdminController
    include MessageEmitter

    before_action :set_job

    def create
      with_message_service do
        Jobs::JobsReactor.new(message_service:).create_job_attribute(
          job_id: job.id,
          attribute_id: params[:job_attribute][:attribute_id],
          acceptible_set: params[:job_attribute][:acceptible_set]
        )
      end

      head :created
    end

    def update
      with_message_service do
        Jobs::JobsReactor.new(message_service:).update_job_attribute(
          job_id: job.id,
          job_attribute_id: params[:id],
          acceptible_set: params[:job_attribute][:acceptible_set]
        )
      end
    end

    def destroy
      with_message_service do
        Jobs::JobsReactor.new(message_service:).destroy_job_attribute(
          job_id: job.id,
          job_attribute_id: params[:id]
        )
      end
    end

    private

    attr_reader :job

    def set_job
      @job = Job.find(params[:job_id])
    end
  end
end

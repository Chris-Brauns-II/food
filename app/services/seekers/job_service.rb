module Seekers
  class JobService
    include MessageEmitter

    def initialize(job:, seeker:)
      @job = job
      @seeker = seeker
    end

    def add_elevator_pitch(elevator_pitch)
      message_service.create!(
        schema: Events::ElevatorPitchCreated::V2,
        person_id: seeker.id,
        data: {
          job_id: job.id,
          pitch: elevator_pitch
        }
      )
    end

    private

    attr_reader :job, :seeker
  end
end

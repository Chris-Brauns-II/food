class Onboarding
  module Steps
    ALL = [
      START = 'start'.freeze,
      RELIABILITY = 'reliability'.freeze,
      EMPLOYMENT = 'employment'.freeze,
      EDUCATION = "education".freeze,
      TRAINING = "training".freeze,
      OPPORTUNITIES = "opportunities".freeze,
      COMPLETE_LOADING = "complete_loading".freeze,
      COMPLETE = "complete".freeze
    ].freeze
  end

  def initialize(message_service:, person_id:, user_id:, trace_id:)
    @person_id = person_id
    @trace_id = trace_id
    @user_id = user_id
    @event_emitter = People::PersonEventEmitter.new(message_service:)
  end

  def update(responses:)
    update_reliability(retrieve_response_for(responses, "reliability")) if response_for?(responses, "reliability")
    update_experience(retrieve_response_for(responses, "experience")) if response_for?(responses, "experience")
    update_education(retrieve_response_for(responses, "education")) if response_for?(responses, "education")
    update_training_provider(retrieve_response_for(responses, "training_provider")) if response_for?(responses, "training_provider")
    update_other(retrieve_response_for(responses, "other")) if response_for?(responses, "other")
    update_interests(retrieve_response_for(responses, "opportunity_interests")) if response_for?(responses, "opportunity_interests")
  end

  private

  attr_reader :event_emitter, :user_id, :person_id, :trace_id

  def update_reliability(reliabilities)
    event_emitter.add_reliability(
      person_id:,
      trace_id:,
      reliabilities: reliabilities.map { |r| map_reliabilities(r) }
    )
  end

  def map_reliabilities(reliability)
    case reliability
    when "I've had or currently have a job"
      Reliability::JOB
    when "I've attended a Training Program"
      Reliability::TRAINING_PROGRAM
    when 'I have a High School Diploma / GED'
      Reliability::EDUCATION
    end
  end

  def update_experience(work_responses)
    work_responses.each do |wr|
      event_emitter.add_experience(
        person_id:,
        trace_id:,

        organization_name: wr["company"],
        position: wr["position"],
        start_date: wr["start_date"],
        end_date: wr["end_date"],
        is_current: wr["current"],
        description: wr["description"]
      )
    end
  end

  def update_education(education_responses)
    education_responses.each do |er|
      event_emitter.add_education_experience(
        person_id:,
        trace_id:,

        organization_name: er["org"],
        title: er["title"],
        activities: er["activities"],
        graduation_date: er["grad_year"],
        gpa: er["gpa"]
      )
    end
  end

  def update_training_provider(tp_responses)
    tp_responses.each do |tr|
      event_emitter.add_person_training_provider(
        person_id:,
        trace_id:,
        program_id: nil,
        status: "Enrolled",

        training_provider_id: tr
      )
    end
  end

  def update_other(other_responses)
    other_responses.each do |oth_r|
      event_emitter.add_personal_experience(
        person_id:,
        trace_id:,

        activity: oth_r["activity"],
        description: oth_r["learning"],
        start_date: oth_r["start_date"],
        end_date: oth_r["end_date"]
      )
    end
  end

  def update_interests(opportunity_interests_response)
    event_emitter.add_professional_interests(
      person_id:,
      trace_id:,

      interests: opportunity_interests_response
    )
  end

  def retrieve_response_for(responses, kind)
    responses.dig(kind, "response")
  end

  def response_for?(responses, kind)
    !responses.dig(kind, "response").nil?
  end
end

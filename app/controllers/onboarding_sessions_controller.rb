class OnboardingSessionsController < ApplicationController
  include Secured
  include MessageEmitter

  before_action :authorize

  def show
    render json: serialize_onboarding_session(current_user.person_id)
  end

  def create
    filtered = params.permit(:first_name, :last_name, :phone_number, :date_of_birth).to_h.symbolize_keys

    with_message_service do
      person_id = find_person_id

      if person_id.present?
        message_service.create!(
          person_id:,
          schema: Events::BasicInfoAdded::V1,
          trace_id: request.request_id,
          data: {
            email: current_user.email,
            first_name: filtered[:first_name],
            last_name: filtered[:last_name],
            phone_number: filtered[:phone_number]
          }
        )
        message_service.create!(
          person_id:,
          schema: Events::DateOfBirthAdded::V1,
          trace_id: request.request_id,
          data: {
            date_of_birth: filtered[:date_of_birth]
          }
        )
      else
        message_service.create!(
          person_id: SecureRandom.uuid,
          schema: Commands::AddPerson::V2,
          trace_id: request.request_id,
          data: {
            user_id: current_user.id,
            first_name: filtered[:first_name],
            last_name: filtered[:last_name],
            phone_number: filtered[:phone_number],
            date_of_birth: filtered[:date_of_birth],
            source_kind: People::SourceKind::USER,
            source_identifier: current_user.id,
            email: current_user.email
          }
        )
      end
    end

    head :created
  end

  def update
    person_id = find_person_id

    if person_id.blank?
      render json: { error: 'Seeker not found' }, status: :bad_request
      return
    end

    filtered = params.require("onboarding_session").permit(
      responses: {
        education: {
          response: %i[
            org
            title
            grad_year
            gpa
            activities
          ]
        },
        experience: {
          response: %i[
            company
            position
            start_date
            current
            end_date
            description
          ]
        },
        opportunity_interests: {
          response: []
        },
        other: {
          response: %i[
            activity
            start_date
            end_date
            learning
          ]
        },
        reliability: {
          response: []
        },
        training_provider: {
          response: []
        }
      }
    ).to_h.symbolize_keys

    responses = filtered[:responses]

    with_message_service do
      Onboarding.new(
        message_service:,
        person_id:,
        user_id: current_user.id,
        trace_id: request.request_id
      ).update(responses:)
    end

    render json: serialize_onboarding_session(person_id)
  end

  private

  def find_person_id
    return current_user.person_id if current_user.person_id.present?

    Events::PersonAssociatedToUser::V1.all_messages.detect do |m|
      m.data.user_id == current_user.id
    end&.stream&.id
  end

  def serialize_onboarding_session(person_id)
    messages = if person_id.nil?
                 []
               else
                 MessageService.stream_events(Streams::Person.new(person_id:))
               end
    status = People::Projectors::OnboardingStatus.new.project(messages)

    {
      seeker_id: person_id,
      person_id:,
      next_step: status.next_step,
      progress: status.progress
    }
  end
end

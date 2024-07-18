require 'rails_helper'

RSpec.describe Klaviyo::KlaviyoReactor do
  it_behaves_like "a replayable message consumer"

  let(:instance) { described_class.new(message_service:, client:) }

  let(:message_service) { MessageService.new }
  let(:client) { Klaviyo::FakeGateway.new }

  describe "#handle_message" do
    subject { instance.handle_message(message) }

    let(:user_id) { SecureRandom.uuid }
    let(:person_id) { SecureRandom.uuid }
    let(:email) { "an@email.com" }

    shared_examples "emits Klaviyo event pushed once" do
      it "only emits the event once" do
        expect(message_service)
          .to receive(:create!)
          .with(
            schema: Events::KlaviyoEventPushed::V1,
            trace_id: message.trace_id,
            event_id: message.id,
            data: Core::Nothing
          )
          .once
          .and_call_original

        instance.handle_message(message)
        instance.handle_message(message)
      end
    end

    context "when the message is user created" do
      let(:message) do
        build(
          :message,
          schema: Events::UserCreated::V1,
          data: {
            first_name: "John"
          }
        )
      end

      it_behaves_like "emits Klaviyo event pushed once"

      it "calls the Klaviyo gateway" do
        expect(client)
          .to receive(:user_signup)
          .with(
            email: message.data.email,
            event_id: message.id,
            occurred_at: message.occurred_at
          )
          .and_call_original

        subject
      end
    end

    context "people messages" do
      before do
        allow_any_instance_of(People::Projectors::Email)
          .to receive(:project)
          .and_return(projection)
      end

      let(:projection) do
        People::Projectors::Email::Projection.new(
          initial_email: email,
          current_email: "another@email.com"
        )
      end

      context "when the message is person added" do
        let(:message) do
          build(
            :message,
            stream_id: person_id,
            schema: Events::PersonAdded::V1,
            data: {
              phone_number: "222-222-2222"
            }
          )
        end

        it_behaves_like "emits Klaviyo event pushed once"

        it "calls the Klaviyo gateway" do
          expect(client)
            .to receive(:person_added)
            .with(
              email:,
              event_id: message.id,
              occurred_at: message.occurred_at,
              profile_attributes: {
                first_name: message.data.first_name,
                last_name: message.data.last_name,
                phone_number: '+12222222222'
              },
              profile_properties: {
                date_of_birth: message.data.date_of_birth
              }
            )
            .and_call_original

          subject
        end
      end

      context "when the message is basic info added" do
        let(:message) do
          build(
            :message,
            stream_id: person_id,
            schema: Events::BasicInfoAdded::V1,
            data: {
              phone_number: "222-222-2222"
            }
          )
        end

        it_behaves_like "emits Klaviyo event pushed once"

        it "calls the Klaviyo gateway" do
          expect(client)
            .to receive(:user_updated)
            .with(
              email:,
              event_id: message.id,
              occurred_at: message.occurred_at,
              profile_properties: {},
              profile_attributes: {
                first_name: message.data.first_name,
                last_name: message.data.last_name,
                phone_number: '+12222222222'
              }
            )
            .and_call_original

          subject
        end
      end

      context "when the message is education experience added" do
        let(:message) do
          build(
            :message,
            stream_id: person_id,
            schema: Events::EducationExperienceAdded::V2
          )
        end

        it_behaves_like "emits Klaviyo event pushed once"

        it "calls the Klaviyo gateway" do
          expect(client)
            .to receive(:education_experience_entered)
            .with(
              email:,
              event_id: message.id,
              occurred_at: message.occurred_at
            )
            .and_call_original

          subject
        end
      end

      context "when the message is experience added" do
        let(:message) do
          build(
            :message,
            stream_id: person_id,
            schema: Events::ExperienceAdded::V2
          )
        end

        it_behaves_like "emits Klaviyo event pushed once"

        it "calls the Klaviyo gateway" do
          expect(client)
            .to receive(:experience_entered)
            .with(
              email:,
              event_id: message.id,
              occurred_at: message.occurred_at
            )
            .and_call_original

          subject
        end
      end

      context "when the message is onboarding completed" do
        let(:message) do
          build(
            :message,
            stream_id: person_id,
            schema: Events::OnboardingCompleted::V3
          )
        end

        it_behaves_like "emits Klaviyo event pushed once"

        it "calls the Klaviyo gateway" do
          expect(client)
            .to receive(:onboarding_complete)
            .with(
              email:,
              event_id: message.id,
              occurred_at: message.occurred_at
            )
            .and_call_original

          subject
        end
      end
    end

    context "when the message is chat message sent" do
      before do
        message_service.create!(
          schema: Events::ApplicantStatusUpdated::V6,
          application_id:,
          data: {
            applicant_first_name: "First",
            applicant_last_name: "Last",
            applicant_email: email,
            applicant_phone_number: "333-333-3333",
            seeker_id: SecureRandom.uuid,
            user_id:,
            job_id: SecureRandom.uuid,
            employer_name: "Employer",
            employment_title: "Job",
            status: ApplicantStatus::StatusTypes::NEW,
            reasons: []
          },
          metadata: {
            user_id:
          }
        )
      end

      let(:message) do
        build(
          :message,
          schema: Events::ChatMessageSent::V2,
          stream_id: application_id,
          data: {
            from_user_id:
          }
        )
      end
      let(:application_id) { SecureRandom.uuid }
      let(:from_user_id) { SecureRandom.uuid }

      it_behaves_like "emits Klaviyo event pushed once"

      context "when the message is from the applicant" do
        let(:from_user_id) { user_id }

        it "does nothing" do
          expect(client)
            .not_to receive(:chat_message_received)

          subject
        end
      end

      context "when the message is from the employer" do
        let(:from_user_id) { SecureRandom.uuid }

        it "calls the Klaviyo gateway" do
          expect(client)
            .to receive(:chat_message_received)
            .with(
              applicant_id: application_id,
              email:,
              employment_title: "Job",
              employer_name: "Employer",
              event_id: message.id,
              occurred_at: message.occurred_at
            )
            .and_call_original

          subject
        end
      end
    end

    context "when the message is job saved" do
      before do
        message_service.create!(
          schema: Events::UserCreated::V1,
          user_id:,
          data: {
            email:,
            first_name: "Cool",
            last_name: "Seeker"
          }
        )
      end

      let(:message) do
        build(
          :message,
          stream_id: user_id,
          schema: Events::JobSaved::V1
        )
      end

      it_behaves_like "emits Klaviyo event pushed once"

      it "calls the Klaviyo gateway" do
        expect(client)
          .to receive(:job_saved)
          .with(
            email:,
            event_id: message.id,
            event_properties: {
              job_id: message.data.job_id,
              employment_title: message.data.employment_title,
              employer_name: message.data.employer_name
            },
            occurred_at: message.occurred_at
          )
          .and_call_original

        subject
      end
    end

    context "when the message is employer invite accepted" do
      let(:message) do
        build(
          :message,
          schema: Events::EmployerInviteAccepted::V2,
          data: {
            invite_email: "example@email.com",
            employer_name: "Employer"
          }
        )
      end

      it_behaves_like "emits Klaviyo event pushed once"

      it "calls the Klaviyo gateway" do
        expect(client)
          .to receive(:employer_invite_accepted)
          .with(
            event_id: message.id,
            email: "example@email.com",
            profile_properties: {
              is_recruiter: true,
              employer_name: "Employer",
              employer_id: message.data.employer_id
            },
            occurred_at: message.occurred_at
          )
          .and_call_original

        subject
      end
    end

    context "when the message is training provider invite accepted" do
      let(:message) do
        build(
          :message,
          schema: Events::TrainingProviderInviteAccepted::V2,
          data: {
            invite_email: "trainer@email.com",
            training_provider_name: "Trainer"
          }
        )
      end

      it_behaves_like "emits Klaviyo event pushed once"

      it "calls the Klaviyo gateway" do
        expect(client)
          .to receive(:training_provider_invite_accepted)
          .with(
            event_id: message.id,
            email: "trainer@email.com",
            profile_properties: {
              is_training_provider: true,
              training_provider_name: "Trainer",
              training_provider_id: message.data.training_provider_id
            },
            occurred_at: message.occurred_at
          )
          .and_call_original

        subject
      end
    end

    context "when the message is applicant status updated" do
      let(:message) do
        build(
          :message,
          schema: Events::ApplicantStatusUpdated::V6,
          data: {
            applicant_first_name: "First",
            applicant_last_name: "Last",
            applicant_email: "applicant@email.com",
            applicant_phone_number: "333-333-3333",
            employer_name: "Employer",
            employment_title: "Job",
            status: ApplicantStatus::StatusTypes::NEW,
            reasons: []
          },
          metadata: {
            user_id: SecureRandom.uuid
          }
        )
      end

      it_behaves_like "emits Klaviyo event pushed once"

      it "calls the Klaviyo gateway" do
        expect(client)
          .to receive(:application_status_updated)
          .with(
            application_id: message.stream.id,
            email: "applicant@email.com",
            employment_title: "Job",
            employer_name: "Employer",
            event_id: message.id,
            occurred_at: message.occurred_at,
            status: ApplicantStatus::StatusTypes::NEW
          )
          .and_call_original

        subject
      end
    end
  end
end

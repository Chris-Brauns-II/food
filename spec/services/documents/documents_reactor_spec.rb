require 'rails_helper'

RSpec.describe Documents::DocumentsReactor do
  it_behaves_like "a replayable message consumer"

  before do
    messages.each do |message|
      Event.from_message!(message)
    end
  end

  let(:consumer) { described_class.new(message_service:, document_storage:) }
  let(:document_storage) { Documents::Storage::DbOnlyCommunicator.new }
  let(:storage_kind) { Documents::StorageKind::POSTGRES }
  let(:message_service) { MessageService.new }
  let(:trace_id) { SecureRandom.uuid }
  let(:messages) { [] }
  let(:person_stream) { Streams::Person.new(person_id:) }
  let(:person_id) { SecureRandom.uuid }
  let(:answers_stream) { Screeners::Streams::Answers.new(screener_answers_id:) }
  let(:screener_answers_id) { SecureRandom.uuid }

  describe "#handle_message" do
    subject { consumer.handle_message(message) }

    context "when the message is generate resume for person" do
      let(:message) do
        build(
          :message,
          schema: Documents::Commands::GenerateResumeForPerson::V2,
          data: {
            person_id:,
            anonymized: true,
            checks: [Documents::Checks::BACKGROUND],
            document_kind: Documents::DocumentKind::PDF,
            page_limit: 1
          },
          metadata: {
            requestor_type: Requestor::Kinds::USER,
            requestor_id: SecureRandom.uuid
          }
        )
      end

      context "when there are no messages for the person" do
        it "emits resume generation requested and resume generation failed events" do
          expect(message_service)
            .to receive(:create_once_for_trace!)
            .with(
              trace_id: message.trace_id,
              stream: message.stream,
              schema: Documents::Events::ResumeGenerationRequested::V1,
              data: {
                person_id: message.data.person_id,
                anonymized: message.data.anonymized,
                document_kind: message.data.document_kind
              },
              metadata: message.metadata
            )
            .and_call_original

          expect(message_service)
            .to receive(:create_once_for_trace!)
            .with(
              trace_id: message.trace_id,
              stream: message.stream,
              schema: Documents::Events::ResumeGenerationFailed::V1,
              data: {
                person_id: message.data.person_id,
                anonymized: message.data.anonymized,
                document_kind: message.data.document_kind,
                reason: "Person does not exist"
              },
              metadata: message.metadata
            )
            .and_call_original

          subject
        end
      end

      context "when there are messages for the person" do
        let(:person_added) do
          build(
            :message,
            stream: person_stream,
            schema: Events::PersonAdded::V1,
            data: {
              first_name: "Jim",
              last_name: "Bo",
              email: "a@b.com",
              phone_number: nil,
              date_of_birth: nil
            }
          )
        end
        let(:person_about_added) do
          build(
            :message,
            stream: person_stream,
            schema: Events::PersonAboutAdded::V1,
            data: {
              about: "I'm pretty cool"
            }
          )
        end
        let(:work_experience_added) do
          build(
            :message,
            stream: person_stream,
            schema: Events::ExperienceAdded::V2,
            data: {
              id: SecureRandom.uuid,
              organization_name: "SuperQuik",
              position: "Clerk",
              start_date: "today",
              end_date: nil,
              description: "I did stuff",
              is_current: true
            }
          )
        end
        let(:education_experience_added) do
          build(
            :message,
            stream: person_stream,
            schema: Events::EducationExperienceAdded::V2,
            data: {
              id: SecureRandom.uuid,
              organization_name: "Westervill High School",
              title: "Student",
              activities: "Clowning",
              graduation_date: "2023",
              gpa: nil
            }
          )
        end
        let(:messages) do
          [
            person_added,
            person_about_added,
            work_experience_added,
            education_experience_added
          ]
        end

        it "emits resume generation requested and generate resume events" do
          expect(message_service)
            .to receive(:create_once_for_trace!)
            .with(
              trace_id: message.trace_id,
              stream: message.stream,
              schema: Documents::Events::ResumeGenerationRequested::V1,
              data: {
                person_id: message.data.person_id,
                anonymized: message.data.anonymized,
                document_kind: message.data.document_kind
              },
              metadata: message.metadata
            )
            .and_call_original

          expect(message_service)
            .to receive(:create_once_for_trace!)
            .with(
              trace_id: message.trace_id,
              stream: message.stream,
              schema: Documents::Commands::GenerateResume::V3,
              data: {
                person_id: message.data.person_id,
                anonymized: message.data.anonymized,
                checks: message.data.checks,
                document_kind: message.data.document_kind,
                page_limit: message.data.page_limit,
                first_name: person_added.data.first_name,
                last_name: person_added.data.last_name,
                email: person_added.data.email,
                phone_number: person_added.data.phone_number,
                bio: person_about_added.data.about,
                work_experiences: [
                  Documents::Commands::GenerateResume::WorkExperience::V1.new(
                    organization_name: work_experience_added.data.organization_name,
                    position: work_experience_added.data.position,
                    start_date: work_experience_added.data.start_date,
                    end_date: work_experience_added.data.end_date,
                    is_current: work_experience_added.data.is_current,
                    description: work_experience_added.data.description
                  )
                ],
                education_experiences: [
                  Documents::Commands::GenerateResume::EducationExperience::V1.new(
                    organization_name: education_experience_added.data.organization_name,
                    title: education_experience_added.data.title,
                    activities: education_experience_added.data.activities,
                    graduation_date: education_experience_added.data.graduation_date,
                    gpa: education_experience_added.data.gpa
                  )
                ]
              },
              metadata: message.metadata
            )
            .and_call_original

          subject
        end
      end
    end

    context "when the message is generate resume" do
      let(:message) do
        build(
          :message,
          schema: Documents::Commands::GenerateResume::V3,
          data: {
            person_id:,
            anonymized: true,
            checks: [Documents::Checks::DRUG],
            document_kind: Documents::DocumentKind::PDF,
            page_limit: 1,
            first_name: "First",
            last_name: "Name",
            email: "Email",
            phone_number: "Phone Number",
            bio: "Bio",
            work_experiences: [
              Documents::Commands::GenerateResume::WorkExperience::V1.new(
                organization_name: "Org",
                position: "Position",
                start_date: "Start",
                end_date: "End",
                is_current: false,
                description: "Description"
              )
            ],
            education_experiences: [
              Documents::Commands::GenerateResume::EducationExperience::V1.new(
                organization_name: "Org",
                title: "Title",
                activities: nil,
                graduation_date: "2019",
                gpa: "2.5"
              )
            ]
          },
          metadata: {
            requestor_type: Requestor::Kinds::USER,
            requestor_id: SecureRandom.uuid
          },
          occurred_at: Time.zone.local(2000, 1, 1)
        )
      end

      context "when sucessful" do
        it "calls the resume generation service, stores it and emits an resume generated event" do
          expect(Documents::ResumeGenerationService)
            .to receive(:generate_from_command)
            .with(message:)
            .and_call_original

          expect(document_storage)
            .to receive(:store_document)
            .with(
              id: message.stream.id,
              storage_kind:,
              file_data: be_a(String),
              file_name: "First-Name-resume-2000-01-01-00:00.pdf"
            )
            .and_call_original

          expect(message_service)
            .to receive(:create_once_for_trace!)
            .with(
              trace_id: message.trace_id,
              stream: message.stream,
              schema: Documents::Events::ResumeGenerated::V1,
              data: {
                person_id: message.data.person_id,
                anonymized: message.data.anonymized,
                document_kind: message.data.document_kind,
                storage_kind:,
                storage_identifier: message.stream.id
              },
              metadata: message.metadata
            ).and_call_original

          subject
        end
      end

      context "when an error occurs" do
        before do
          allow(Documents::ResumeGenerationService)
            .to receive(:generate_from_command)
            .and_raise(error)
        end

        let(:error) { StandardError.new("Help!") }

        it "emits an resume generated failed event" do
          expect(Sentry)
            .to receive(:capture_exception)
            .with(error)

          expect(message_service)
            .to receive(:create_once_for_trace!)
            .with(
              trace_id: message.trace_id,
              stream: message.stream,
              schema: Documents::Events::ResumeGenerationFailed::V1,
              data: {
                person_id: message.data.person_id,
                anonymized: message.data.anonymized,
                document_kind: message.data.document_kind,
                reason: "Help!"
              },
              metadata: message.metadata
            ).and_call_original

          subject
        end
      end
    end

    context "when the message is generate screener for answers" do
      let(:message) do
        build(
          :message,
          schema: Documents::Commands::GenerateScreenerForAnswers::V1,
          data: {
            screener_answers_id:,
            document_kind: Documents::DocumentKind::PDF
          },
          metadata: {
            requestor_type: Requestor::Kinds::USER,
            requestor_id: SecureRandom.uuid
          }
        )
      end

      context "when there are no messages for the answers" do
        it "emits resume generation requested and resume generation failed events" do
          expect(message_service)
            .to receive(:create_once_for_trace!)
            .with(
              trace_id: message.trace_id,
              stream: message.stream,
              schema: Documents::Events::ScreenerGenerationRequested::V1,
              data: {
                screener_answers_id: message.data.screener_answers_id,
                document_kind: message.data.document_kind
              },
              metadata: message.metadata
            )
            .and_call_original

          expect(message_service)
            .to receive(:create_once_for_trace!)
            .with(
              trace_id: message.trace_id,
              stream: message.stream,
              schema: Documents::Events::ScreenerGenerationFailed::V1,
              data: {
                person_id: nil,
                screener_answers_id: message.data.screener_answers_id,
                document_kind: message.data.document_kind,
                reason: "Screener Answers do not exist"
              },
              metadata: message.metadata
            )
            .and_call_original

          subject
        end
      end

      context "when there are messages for the answers" do
        let(:answers_created) do
          build(
            :message,
            stream: answers_stream,
            schema: Screeners::Events::AnswersCreated::V2,
            data: {
              person_id:,
              title: "Dude",
              screener_questions_id: SecureRandom.uuid,
              question_responses: [
                Screeners::QuestionResponse.new(
                  question: "Dude where's my car?",
                  response: "Huh?"
                )
              ]
            }
          )
        end
        let(:answers_updated) do
          build(
            :message,
            stream: answers_stream,
            schema: Screeners::Events::AnswersUpdated::V1,
            data: {
              title: "Dude...",
              question_responses: [
                Screeners::QuestionResponse.new(
                  question: "What's your favorite flavor?",
                  response: "Cherry"
                )
              ]
            },
            occurred_at: Time.zone.local(2021, 1, 1)
          )
        end
        let(:messages) do
          [
            answers_created,
            answers_updated
          ]
        end

        it "emits resume generation requested and generate resume events" do
          expect(message_service)
            .to receive(:create_once_for_trace!)
            .with(
              trace_id: message.trace_id,
              stream: message.stream,
              schema: Documents::Events::ScreenerGenerationRequested::V1,
              data: {
                screener_answers_id: message.data.screener_answers_id,
                document_kind: message.data.document_kind
              },
              metadata: message.metadata
            )
            .and_call_original

          expect(message_service)
            .to receive(:create_once_for_trace!)
            .with(
              trace_id: message.trace_id,
              stream: message.stream,
              schema: Documents::Commands::GenerateScreener::V1,
              data: {
                screener_answers_id: message.data.screener_answers_id,
                title: answers_updated.data.title,
                person_id: answers_created.data.person_id,
                question_responses: answers_updated.data.question_responses,
                document_kind: message.data.document_kind
              },
              metadata: message.metadata
            )
            .and_call_original

          subject
        end
      end
    end

    context "when the message is generate screener" do
      let(:message) do
        build(
          :message,
          schema: Documents::Commands::GenerateScreener::V1,
          data: {
            person_id:,
            screener_answers_id:,
            title: "Bro",
            document_kind: Documents::DocumentKind::PDF,
            question_responses: [
              Screeners::QuestionResponse.new(
                question: "How old are you?",
                response: "12"
              )
            ]
          },
          metadata: {
            requestor_type: Requestor::Kinds::USER,
            requestor_id: SecureRandom.uuid,
            requestor_email: "dude@email.com"
          },
          occurred_at: Time.zone.local(2000, 1, 1)
        )
      end

      context "when sucessful" do
        it "calls the resume generation service, stores it and emits an resume generated event" do
          expect(Documents::ScreenerGenerationService)
            .to receive(:generate_from_command)
            .with(message:)
            .and_call_original

          expect(document_storage)
            .to receive(:store_document)
            .with(
              id: message.stream.id,
              storage_kind:,
              file_data: be_a(String),
              file_name: "screener-#{screener_answers_id}-2000-01-01-00:00.pdf"
            )
            .and_call_original

          expect(message_service)
            .to receive(:create_once_for_trace!)
            .with(
              trace_id: message.trace_id,
              stream: message.stream,
              schema: Documents::Events::ScreenerGenerated::V1,
              data: {
                person_id: message.data.person_id,
                screener_answers_id: message.data.screener_answers_id,
                document_kind: message.data.document_kind,
                storage_kind:,
                storage_identifier: message.stream.id
              },
              metadata: message.metadata
            ).and_call_original

          subject
        end
      end

      context "when an error occurs" do
        before do
          allow(Documents::ScreenerGenerationService)
            .to receive(:generate_from_command)
            .and_raise(error)
        end

        let(:error) { StandardError.new("Help!") }

        it "emits an resume generated failed event" do
          expect(Sentry)
            .to receive(:capture_exception)
            .with(error)

          expect(message_service)
            .to receive(:create_once_for_trace!)
            .with(
              trace_id: message.trace_id,
              stream: message.stream,
              schema: Documents::Events::ScreenerGenerationFailed::V1,
              data: {
                person_id: message.data.person_id,
                screener_answers_id: message.data.screener_answers_id,
                document_kind: message.data.document_kind,
                reason: "Help!"
              },
              metadata: message.metadata
            ).and_call_original

          subject
        end
      end
    end
  end
end

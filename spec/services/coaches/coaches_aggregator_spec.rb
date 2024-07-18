require 'rails_helper'

RSpec.describe Coaches::CoachesAggregator do
  let(:consumer) { described_class.new }
  let(:id) { SecureRandom.uuid }

  it_behaves_like "a replayable message consumer"

  describe "#handle_message" do
    subject { consumer.handle_message(message) }

    context "when the message is barrier_added" do
      let(:message) do
        build(
          :message,
          schema: Events::BarrierAdded::V1,
          data: {
            barrier_id: id,
            name: "A lame barrier"
          }
        )
      end

      it "Creates a barrier record" do
        expect { subject }.to change {
          Barrier.count
        }.from(0).to(1)

        barrier = Barrier.last_created
        expect(barrier.barrier_id).to eq(id)
        expect(barrier.name).to eq("A lame barrier")
      end
    end

    context "when the message is person added" do
      let(:message) do
        build(
          :message,
          schema: Events::PersonAdded::V1,
          data: {
            first_name: "Hannah",
            last_name: "Block",
            email: "Some@email.com",
            date_of_birth: "10/09/1990",
            phone_number: "333-333-3333"
          }
        )
      end

      it "Creates a barrier record" do
        expect { subject }
          .to change(Coaches::PersonContext, :count)
          .from(0).to(1)

        person_context = Coaches::PersonContext.first

        expect(person_context.id).to eq(message.stream_id)
        expect(person_context.email).to eq(message.data.email)
        expect(person_context.phone_number).to eq(message.data.phone_number)
        expect(person_context.person_captured_at).to eq(message.occurred_at)
        expect(person_context.first_name).to eq(message.data.first_name)
        expect(person_context.last_name).to eq(message.data.last_name)
        expect(person_context.last_active_on).to eq(message.occurred_at)
        expect(person_context.kind).to eq(Coaches::PersonContext::Kind::LEAD)
      end
    end

    context "when the message is coach added" do
      let(:message) do
        build(
          :message,
          schema: Events::CoachAdded::V1,
          data: {
            email: "some@email.com",
            coach_id: id
          }
        )
      end

      it "Creates a coach record" do
        expect { subject }.to change {
          Coaches::Coach.count
        }.from(0).to(1)

        coach = Coaches::Coach.first
        expect(coach.email).to eq("some@email.com")
        expect(coach.id).to eq(id)
        expect(coach.assignment_weight).to eq(0)
      end
    end

    context "when the message is coach assignment weight added" do
      let(:message) do
        build(
          :message,
          schema: Events::CoachAssignmentWeightAdded::V1,
          stream: Streams::Coach.new(coach_id: coach.id),
          data: {
            weight: 0.35
          }
        )
      end

      let(:coach) { create(:coaches__coach) }

      it "Updates a coach record" do
        subject

        coach.reload
        expect(coach.assignment_weight).to eq(0.35)
      end
    end

    context "when the message is job_created" do
      let(:message) do
        build(
          :message,
          stream_id: id,
          schema: Events::JobCreated::V3,
          data: {
            category: Job::Categories::MARKETPLACE,
            employment_title: "Laborer",
            employer_name: "Employer",
            employer_id: SecureRandom.uuid,
            benefits_description: "Benefits",
            responsibilities_description: "Responsibilities",
            location: "Columbus, OH",
            employment_type: "FULLTIME",
            hide_job: false,
            schedule: "9-5",
            work_days: "M-F",
            requirements_description: "Requirements",
            industry: [Job::Industries::MANUFACTURING]
          }
        )
      end

      it "Creates a job record" do
        expect { subject }.to change {
          Coaches::Job.count
        }.from(0).to(1)

        job = Coaches::Job.last_created
        expect(job.job_id).to eq(id)
        expect(job.employment_title).to eq("Laborer")
        expect(job.employer_name).to eq("Employer")
        expect(job.hide_job).to eq(false)
      end
    end

    context "when the message is job_updated" do
      let(:message) do
        build(
          :message,
          stream_id: id,
          schema: Events::JobUpdated::V2,
          data: {
            category: Job::Categories::MARKETPLACE,
            employment_title: "Laborer",
            benefits_description: "Benefits",
            responsibilities_description: "Responsibilities",
            location: "Columbus, OH",
            employment_type: "FULLTIME",
            hide_job: false,
            schedule: "9-5",
            work_days: "M-F",
            requirements_description: "Requirements",
            industry: [Job::Industries::MANUFACTURING]
          }
        )
      end

      let!(:job) { create(:coaches__job, job_id: id) }

      it "Updates a job record" do
        expect { subject }.not_to(change do
          Coaches::Job.count
        end)

        job.reload
        expect(job.job_id).to eq(id)
        expect(job.employment_title).to eq("Laborer")
        expect(job.hide_job).to eq(false)
      end
    end

    context "for coaches" do
      let!(:coach) { create(:coaches__coach) }

      context "when the message is coach reminder" do
        let(:message) do
          build(
            :message,
            schema: Events::CoachReminderScheduled::V2,
            stream_id: coach.id,
            data: {
              reminder_id: SecureRandom.uuid,
              person_id: nil,
              note: "Remember to do this later",
              message_task_id: SecureRandom.uuid,
              reminder_at: Time.zone.local(2100, 1, 1)
            }
          )
        end

        it "Creates a reminder" do
          expect { subject }.to change {
            Coaches::Reminder.count
          }.from(0).to(1)

          reminder = Coaches::Reminder.first
          expect(reminder.coach).to eq(coach)
          expect(reminder.id).to eq(message.data.reminder_id)
          expect(reminder.person_id).to eq(message.data.person_id)
          expect(reminder.note).to eq(message.data.note)
          expect(reminder.message_task_id).to eq(message.data.message_task_id)
          expect(reminder.reminder_at).to eq(message.data.reminder_at)
          expect(reminder.state).to eq(Coaches::ReminderState::SET)
        end
      end
    end

    context "for coach seekers context" do
      let!(:person_context) { create(:coaches__person_context, user_id:, id: person_id) }
      let(:person_id) { SecureRandom.uuid }
      let(:user_id) { SecureRandom.uuid }

      context "when the message is applicant_status_updated" do
        let(:message) do
          build(
            :message,
            schema: Events::ApplicantStatusUpdated::V6,
            stream_id: applicant_id,
            data: {
              job_id:,
              applicant_first_name: "Hannah",
              applicant_last_name: "Block",
              applicant_email: "hannah@hannah.com",
              applicant_phone_number: "1234567890",
              employer_name: "Employer",
              seeker_id: person_context.id,
              user_id: person_context.user_id,
              employment_title: "Software Engineer",
              status: ApplicantStatus::StatusTypes::NEW
            },
            metadata: {}
          )
        end
        let(:job_id) { SecureRandom.uuid }
        let(:applicant_id) { SecureRandom.uuid }

        it "Creates a feed event" do
          expect { subject }.to change {
            Coaches::FeedEvent.count
          }.from(0).to(1)

          feed_event = Coaches::FeedEvent.last_created
          expect(feed_event.context_id).to eq(person_context.id)
          expect(feed_event.occurred_at).to eq(message.occurred_at)
          expect(feed_event.seeker_email).to eq("hannah@hannah.com")
          expect(feed_event.description).to eq("Hannah Block's application for Software Engineer at Employer has been updated to new.")
        end

        context "when there is an existing seeker application" do
          before do
            create(
              :coaches__person_application,
              person_context:,
              id: applicant_id
            )
          end

          it "Update the seeker application" do
            expect { subject }.not_to(change do
              Coaches::PersonApplication.count
            end)

            applications = Coaches::PersonApplication.first
            expect(applications.status).to eq(ApplicantStatus::StatusTypes::NEW)
            expect(applications.employer_name).to eq("Employer")
            expect(applications.job_id).to eq(job_id)
            expect(applications.employment_title).to eq("Software Engineer")
          end
        end

        context "when there isn't an existing seeker application" do
          it "Creates the seeker application" do
            expect { subject }.to change {
                                    Coaches::PersonApplication.count
                                  }.from(0).to(1)

            applications = Coaches::PersonApplication.first
            expect(applications.status).to eq(ApplicantStatus::StatusTypes::NEW)
            expect(applications.employer_name).to eq("Employer")
            expect(applications.job_id).to eq(job_id)
            expect(applications.employment_title).to eq("Software Engineer")
          end
        end
      end

      context "when the message is note added" do
        let(:message) do
          build(
            :message,
            schema: Events::NoteAdded::V4,
            stream_id: person_id,
            data: {
              note_id: SecureRandom.uuid,
              note: "A note",
              originator: "the universe"
            }
          )
        end

        it "Creates a Seeker Note" do
          expect { subject }.to change(Coaches::PersonNote, :count).from(0).to(1)

          seeker_note = Coaches::PersonNote.first
          expect(seeker_note.person_context).to eq(person_context)
          expect(seeker_note.note_taken_at).to eq(message.occurred_at)
          expect(seeker_note.note_taken_by).to eq(message.data.originator)
          expect(seeker_note.id).to eq(message.data.note_id)
          expect(seeker_note.note).to eq(message.data.note)
        end
      end

      context "when the message is barrier updated" do
        let(:message) do
          build(
            :message,
            schema: Events::BarrierUpdated::V3,
            stream_id: person_id,
            data: {
              barriers: [SecureRandom.uuid]
            }
          )
        end

        it "Updates barriers" do
          subject

          person_context.reload
          expect(person_context.barriers).to eq(message.data.barriers)
        end
      end

      context "when the message is person sourced" do
        let(:message) do
          build(
            :message,
            schema: Events::PersonSourced::V1,
            stream_id: person_id,
            data: {
              source_kind: People::SourceKind::COACH,
              source_identifier: coach.id
            }
          )
        end

        let(:coach) { create(:coaches__coach) }

        it "Updates the coach seeker context" do
          subject

          person_context.reload
          expect(person_context.captured_by).to eq(coach.email)
        end
      end

      context "when the message is note modified" do
        let(:message) do
          build(
            :message,
            schema: Events::NoteModified::V4,
            stream_id: person_id,
            data: {
              note_id: seeker_note.id,
              note: "A new note",
              originator: "your friend"
            }
          )
        end

        let(:seeker_note) { create(:coaches__person_note, person_context:) }

        it "Modifies a Seeker Note" do
          subject

          seeker_note.reload
          expect(seeker_note.note).to eq(message.data.note)
        end
      end

      context "when the message is note deleted" do
        let(:message) do
          build(
            :message,
            schema: Events::NoteDeleted::V4,
            stream_id: person_id,
            data: {
              note_id: seeker_note.id,
              originator: "your enemy"
            }
          )
        end

        let!(:seeker_note) { create(:coaches__person_note, person_context:) }

        it "Removes a Seeker Note" do
          expect { subject }.to change(Coaches::PersonNote, :count).from(1).to(0)
        end
      end

      context "when the message is seeker attribute added" do
        let(:message) do
          build(
            :message,
            schema: Events::PersonAttributeAdded::V1,
            stream_id: person_id,
            data: {
              id: SecureRandom.uuid,
              attribute_id: SecureRandom.uuid,
              attribute_name: "HS Cliques",
              attribute_values: ["Jock"]
            }
          )
        end

        it "Creates a Seeker Attribute" do
          expect { subject }.to change(Coaches::PersonAttribute, :count).from(0).to(1)

          seeker_attribute = Coaches::PersonAttribute.first
          expect(seeker_attribute.person_context).to eq(person_context)
          expect(seeker_attribute.id).to eq(message.data.id)
          expect(seeker_attribute.attribute_id).to eq(message.data.attribute_id)
          expect(seeker_attribute.name).to eq("HS Cliques")
          expect(seeker_attribute.values).to eq(["Jock"])
        end
      end

      context "when the message is session started" do
        let(:message) do
          build(
            :message,
            schema: Events::SessionStarted::V1,
            stream_id: user_id,
            data: Core::Nothing
          )
        end

        it "Updates the coach seeker context" do
          subject

          person_context.reload
          expect(person_context.last_active_on).to eq(message.occurred_at)
        end
      end

      context "when the message is person certified" do
        let(:message) do
          build(
            :message,
            schema: Events::PersonCertified::V1,
            stream_id: person_id,
            data: {
              coach_first_name: "Coach",
              coach_last_name: "K",
              coach_email: "katina@skillarc.com",
              coach_id: coach.id
            }
          )
        end

        let(:coach) { create(:coaches__coach) }

        it "Updates certified by" do
          subject

          person_context.reload
          expect(person_context.certified_by).to eq(coach.email)
        end
      end

      context "when the message is coach assigned" do
        let(:message) do
          build(
            :message,
            schema: Events::CoachAssigned::V3,
            stream_id: person_id,
            data: {
              coach_id: coach.id
            }
          )
        end

        let(:coach) { create(:coaches__coach) }

        it "Updates the assigned coach" do
          subject

          person_context.reload
          expect(person_context.assigned_coach).to eq(coach.email)
        end
      end

      context "when the message is job recommended" do
        let(:message) do
          build(
            :message,
            schema: Events::JobRecommended::V3,
            stream_id: person_id,
            data: {
              coach_id: coach.id,
              job_id: job.job_id
            }
          )
        end

        let(:coach) { create(:coaches__coach) }
        let(:job) { create(:coaches__job) }

        it "Creates a recommendation" do
          expect { subject }.to change(Coaches::PersonJobRecommendation, :count).from(0).to(1)

          recommendation = Coaches::PersonJobRecommendation.take(1).first
          expect(recommendation.job).to eq(job)
          expect(recommendation.coach).to eq(coach)
        end
      end

      context "when the message is person associated with user" do
        let(:message) do
          build(
            :message,
            schema: Events::PersonAssociatedToUser::V1,
            stream_id: person_id,
            data: {
              user_id: SecureRandom.uuid
            }
          )
        end

        let(:user_id) { nil }

        it "Updates the coach seeker context" do
          subject

          person_context.reload
          expect(person_context.user_id).to eq(message.data.user_id)
          expect(person_context.kind).to eq(Coaches::PersonContext::Kind::SEEKER)
        end
      end

      context "when the message is basic info added" do
        let(:message) do
          build(
            :message,
            schema: Events::BasicInfoAdded::V1,
            stream_id: person_id,
            data: {
              first_name: "Jim",
              last_name: "Bob",
              phone_number: "4444444444",
              email: "some@email.com"
            }
          )
        end

        it "Updates the coach seeker context" do
          subject

          person_context.reload
          expect(person_context.first_name).to eq(message.data.first_name)
          expect(person_context.last_name).to eq(message.data.last_name)
          expect(person_context.phone_number).to eq(message.data.phone_number)
          expect(person_context.email).to eq(message.data.email)
        end
      end

      context "when the message is seeker attribute removed" do
        let(:message) do
          build(
            :message,
            schema: Events::PersonAttributeRemoved::V1,
            stream_id: person_id,
            data: {
              id: seeker_attribute.id
            }
          )
        end

        let!(:seeker_attribute) { create(:coaches__person_attribute, person_context:) }

        it "Creates a Seeker Attribute" do
          expect { subject }.to change(Coaches::PersonAttribute, :count).from(1).to(0)
        end
      end
    end
  end
end

require 'rails_helper'

RSpec.describe Analytics::AnalyticsAggregator do
  it_behaves_like "a replayable message consumer"

  describe "#handle_message" do
    subject { described_class.new.handle_message(message) }

    context "when the message is person_associated_to_user" do
      let(:message) do
        build(
          :message,
          schema: Events::PersonAssociatedToUser::V1,
          stream_id: person_id,
          data: {
            user_id:
          }
        )
      end
      let(:person_id) { SecureRandom.uuid }
      let(:user_id) { SecureRandom.uuid }

      let!(:dim_person) { create(:analytics__dim_person, person_id:) }
      let!(:dim_user) { create(:analytics__dim_user, user_id:) }

      it "sets the foreign key" do
        expect { subject }.to change { dim_person.reload.dim_user&.id }.from(nil).to(dim_user.id)
      end
    end

    describe "when the message is user_created" do
      let(:message) do
        build(
          :message,
          schema: Events::UserCreated::V1,
          stream_id: user_id,
          data: {
            email: "an@email.com",
            first_name: "John",
            last_name: "Chabot",
            sub: SecureRandom.uuid
          }
        )
      end
      let(:user_id) { SecureRandom.uuid }

      context "when the user is created without an email" do
        let(:email) { nil }

        it "creates a dim user for the message" do
          expect { subject }.to change(Analytics::DimUser, :count).from(0).to(1)

          user = Analytics::DimUser.take

          expect(user.user_id).to eq(user_id)
          expect(user.email).to eq(message.data.email)
          expect(user.first_name).to eq(message.data.first_name)
          expect(user.last_name).to eq(message.data.last_name)
        end
      end
    end

    describe "when the message is person added" do
      let(:message) do
        build(
          :message,
          stream_id: person_id,
          schema: Events::PersonAdded::V1,
          data: {
            first_name: "John",
            last_name: "Chabot",
            email: "john@skillarc.com",
            phone_number: "333-333-444",
            date_of_birth: "1990-01-01"
          }
        )
      end
      let(:person_id) { SecureRandom.uuid }

      it "updates a dim person from the message" do
        expect { subject }.to change(Analytics::DimPerson, :count).by(1)

        person = Analytics::DimPerson.first

        expect(person.first_name).to eq(message.data.first_name)
        expect(person.last_name).to eq(message.data.last_name)
        expect(person.email).to eq(message.data.email)
        expect(person.person_id).to eq(person_id)
        expect(person.kind).to eq(Analytics::DimPerson::Kind::LEAD)
      end
    end

    context "for an existing dim_person" do
      before do
        create(
          :analytics__dim_person,
          :seeker,
          email:,
          person_id:
        )
      end

      let(:user_id) { SecureRandom.uuid }
      let(:email) { Faker::Internet.email }
      let(:person_id) { SecureRandom.uuid }

      describe "when the message is basic info added" do
        let(:message) do
          build(
            :message,
            stream_id: person_id,
            schema: Events::BasicInfoAdded::V1,
            data: {
              first_name: "John",
              last_name: "Chabot",
              phone_number: "333-333-444",
              email:
            }
          )
        end

        it "updates a dim person from the message" do
          expect { subject }.not_to change(Analytics::DimPerson, :count)

          person = Analytics::DimPerson.take(1).first

          expect(person.email).to eq(message.data.email)
          expect(person.phone_number).to eq(message.data.phone_number)
          expect(person.first_name).to eq(message.data.first_name)
          expect(person.last_name).to eq(message.data.last_name)
        end
      end

      describe "when the message is onboarding_completed" do
        let(:message) do
          build(
            :message,
            stream_id: person_id,
            schema: Events::OnboardingCompleted::V3,
            data: Core::Nothing
          )
        end

        it "updates a dim person from message" do
          expect { subject }.not_to change(Analytics::DimPerson, :count)

          person = Analytics::DimPerson.take(1).first

          expect(person.onboarding_completed_at).to eq(message.occurred_at)
        end
      end

      describe "when the message is session_started" do
        let(:message) do
          build(
            :message,
            stream_id: user.user_id,
            schema: Events::SessionStarted::V1,
            data: Core::Nothing
          )
        end
        let!(:user) { create(:analytics__dim_user) }

        it "updates a dim user from the message" do
          subject

          expect(user.reload.last_active_at).to eq(message.occurred_at)
        end
      end

      describe "when the message is role_add" do
        let(:message) do
          build(
            :message,
            stream_id: user_id,
            schema: Events::CoachAdded::V1,
            data: {
              email: "an@email.com",
              coach_id: SecureRandom.uuid
            }
          )
        end
        let!(:dim_user) { create(:analytics__dim_user) }
        let(:user_id) { dim_user.user_id }

        it "updates a dim user from the message" do
          expect { subject }.not_to change(Analytics::DimUser, :count)

          expect(dim_user.reload.kind).to eq(Analytics::DimUser::Kind::COACH)
          expect(dim_user.reload.coach_id).to eq(message.data.coach_id)
        end
      end

      describe "when the message is employer_invite_accepted" do
        let(:message) do
          build(
            :message,
            schema: Events::EmployerInviteAccepted::V2,
            data: {
              user_id: user.user_id,
              invite_email: user.email,
              employer_id: SecureRandom.uuid,
              employer_name: "something"
            }
          )
        end
        let!(:user) { create(:analytics__dim_user) }

        it "updates a dim person from the message" do
          expect { subject }.not_to change(Analytics::DimUser, :count)

          expect(user.reload.kind).to eq(Analytics::DimUser::Kind::RECRUITER)
        end
      end

      describe "when the message is training_provider_invite_accepted" do
        let(:message) do
          build(
            :message,
            stream_id: SecureRandom.uuid,
            schema: Events::TrainingProviderInviteAccepted::V2,
            data: {
              training_provider_profile_id: SecureRandom.uuid,
              invite_email: dim_user.email,
              user_id: dim_user.user_id,
              training_provider_id: SecureRandom.uuid,
              training_provider_name: "dawg"
            }
          )
        end
        let!(:dim_user) { create(:analytics__dim_user) }

        it "updates a dim person from the message" do
          expect { subject }.not_to change(Analytics::DimUser, :count)

          expect(dim_user.reload.kind).to eq(Analytics::DimUser::Kind::TRAINING_PROVIDER)
        end
      end
    end

    context "when the message is employer_created" do
      let(:message) do
        build(
          :message,
          schema: Events::EmployerCreated::V1,
          data: {
            name: "name",
            location: "location",
            bio: "bio",
            logo_url: "dope.com"
          }
        )
      end

      it "creates a dim employer for the message" do
        expect { subject }.to change(Analytics::DimEmployer, :count).from(0).to(1)

        employer = Analytics::DimEmployer.first

        expect(employer.employer_id).to eq(message.stream.id)
        expect(employer.name).to eq(message.data.name)
      end
    end

    context "when the message is employer_uopdate" do
      let(:message) do
        build(
          :message,
          schema: Events::EmployerUpdated::V1,
          stream_id: employer.employer_id,
          data: {
            name: "New Name",
            location: "location",
            bio: "bio",
            logo_url: "dope.com"
          }
        )
      end

      let(:employer) { create(:analytics__dim_employer) }

      it "updates a dim employer from the message" do
        subject

        employer.reload
        expect(employer.name).to eq(message.data.name)
      end
    end

    context "when the message is job_order_added" do
      let(:message) do
        build(
          :message,
          schema: JobOrders::Events::Added::V1,
          data: {
            job_id: dim_job.job_id
          }
        )
      end

      let(:dim_job) { create(:analytics__dim_job) }

      it "creates a dim employer for the message" do
        expect { subject }.to change(Analytics::DimJobOrder, :count).from(0).to(1)

        dim_job_order = Analytics::DimJobOrder.first

        expect(dim_job_order.dim_job).to eq(dim_job)
        expect(dim_job_order.job_order_id).to eq(message.stream.id)
        expect(dim_job_order.order_opened_at).to eq(message.occurred_at)
        expect(dim_job_order.employment_title).to eq(dim_job.employment_title)
        expect(dim_job_order.employer_name).to eq(dim_job.employer_name)
      end
    end

    context "for an existing job order" do
      let!(:dim_job_order) do
        create(
          :analytics__dim_job_order,
          job_order_id:,
          order_count:,
          closed_at:,
          closed_status:
        )
      end
      let(:job_order_id) { SecureRandom.uuid }
      let(:order_count) { nil }
      let(:closed_at) { nil }
      let(:closed_status) { nil }

      context "when the message is job_order_stalled" do
        let(:message) do
          build(
            :message,
            stream_id: job_order_id,
            schema: JobOrders::Events::Stalled::V1,
            data: {
              status: JobOrders::StalledStatus::WAITING_ON_EMPLOYER
            }
          )
        end

        let(:closed_at) { Time.zone.now }
        let(:closed_status) { "Closed!!" }

        it "updates the dim job order to clear closed fields" do
          subject

          dim_job_order.reload
          expect(dim_job_order.closed_at).to eq(nil)
          expect(dim_job_order.closed_status).to eq(nil)
        end
      end

      context "when the message is job_order_candidates_screened" do
        let(:message) do
          build(
            :message,
            stream_id: job_order_id,
            schema: JobOrders::Events::CandidatesScreened::V1,
            data: Core::Nothing
          )
        end

        let(:closed_at) { Time.zone.now }
        let(:closed_status) { "Closed!!" }

        it "updates the dim job order to clear closed fields" do
          subject

          dim_job_order.reload
          expect(dim_job_order.closed_at).to eq(nil)
          expect(dim_job_order.closed_status).to eq(nil)
        end
      end

      context "when the message is job_order_filled" do
        let(:message) do
          build(
            :message,
            stream_id: job_order_id,
            schema: JobOrders::Events::Filled::V1,
            data: Core::Nothing
          )
        end

        it "updates the dim job order with closed fields" do
          subject

          dim_job_order.reload
          expect(dim_job_order.closed_at).to eq(message.occurred_at)
          expect(dim_job_order.closed_status).to eq(JobOrders::ClosedStatus::FILLED)
        end
      end

      context "when the message is job_order_not_filled" do
        let(:message) do
          build(
            :message,
            stream_id: job_order_id,
            schema: JobOrders::Events::NotFilled::V1,
            data: Core::Nothing
          )
        end

        it "updates the dim job order with closed fields" do
          subject

          dim_job_order.reload
          expect(dim_job_order.closed_at).to eq(message.occurred_at)
          expect(dim_job_order.closed_status).to eq(JobOrders::ClosedStatus::NOT_FILLED)
        end
      end

      context "when the message is job_order_order_count_added" do
        let(:message) do
          build(
            :message,
            stream_id: job_order_id,
            schema: JobOrders::Events::OrderCountAdded::V1,
            data: {
              order_count: 5
            }
          )
        end

        it "updates the dim job order with an order count" do
          subject

          dim_job_order.reload
          expect(dim_job_order.order_count).to eq(message.data.order_count)
        end
      end
    end

    context "when the message is job_order_candidate_added" do
      let(:message) do
        build(
          :message,
          stream_id: dim_job_order.job_order_id,
          schema: JobOrders::Events::CandidateAdded::V3,
          data: {
            person_id: dim_person.person_id
          },
          metadata: {
            requestor_type: Requestor::Kinds::COACH,
            requestor_id: SecureRandom.uuid,
            requestor_email: "foo@skillarc.com"
          }
        )
      end

      let(:dim_person) { create(:analytics__dim_person) }
      let(:dim_job_order) { create(:analytics__dim_job_order) }
      let!(:other_canidate) { create(:analytics__fact_candidate, dim_job_order:) }

      context "when ther candidate is new" do
        it "creates a new fact candidate with the appropriate values" do
          expect { subject }.to change(Analytics::FactCandidate, :count).from(1).to(2)

          fact_candidate = Analytics::FactCandidate.find_by(dim_person:)

          expect(fact_candidate.dim_person).to eq(dim_person)
          expect(fact_candidate.dim_job_order).to eq(dim_job_order)
          expect(fact_candidate.first_name).to eq(dim_person.first_name)
          expect(fact_candidate.last_name).to eq(dim_person.last_name)
          expect(fact_candidate.email).to eq(dim_person.email)
          expect(fact_candidate.status).to eq(JobOrders::CandidateStatus::ADDED)
          expect(fact_candidate.order_candidate_number).to eq(2)
          expect(fact_candidate.added_at).to eq(message.occurred_at)
          expect(fact_candidate.terminal_status_at).to eq(nil)
          expect(fact_candidate.employer_name).to eq(dim_job_order.employer_name)
          expect(fact_candidate.employment_title).to eq(dim_job_order.employment_title)
          expect(fact_candidate.terminal_status_at).to eq(nil)
        end
      end

      context "when ther candidate is existing" do
        let!(:fact_candidate) { create(:analytics__fact_candidate, dim_job_order:, dim_person:) }

        it "updates the fact candidate with the appropriate values" do
          expect { subject }.not_to change(Analytics::FactCandidate, :count)

          fact_candidate.reload

          expect(fact_candidate.status).to eq(JobOrders::CandidateStatus::ADDED)
          expect(fact_candidate.terminal_status_at).to eq(nil)
        end
      end
    end

    context "for an existing candidate" do
      let!(:fact_candidate) { create(:analytics__fact_candidate) }

      context "when the message is job_order_candidate_hired" do
        let(:message) do
          build(
            :message,
            stream_id: fact_candidate.dim_job_order.job_order_id,
            schema: JobOrders::Events::CandidateHired::V2,
            data: {
              person_id: fact_candidate.dim_person.person_id
            }
          )
        end

        it "updates the fact candidate status" do
          subject

          fact_candidate.reload
          expect(fact_candidate.status).to eq(JobOrders::CandidateStatus::HIRED)
          expect(fact_candidate.terminal_status_at).to eq(message.occurred_at)
        end
      end

      context "when the message is job_order_candidate_recommended" do
        let(:message) do
          build(
            :message,
            stream_id: fact_candidate.dim_job_order.job_order_id,
            schema: JobOrders::Events::CandidateRecommended::V2,
            data: {
              person_id: fact_candidate.dim_person.person_id
            }
          )
        end

        it "updates the fact candidate status" do
          subject

          fact_candidate.reload
          expect(fact_candidate.status).to eq(JobOrders::CandidateStatus::RECOMMENDED)
          expect(fact_candidate.terminal_status_at).to eq(nil)
        end
      end

      context "when the message is job_order_candidate_screened" do
        let(:message) do
          build(
            :message,
            stream_id: fact_candidate.dim_job_order.job_order_id,
            schema: JobOrders::Events::CandidateScreened::V1,
            data: {
              person_id: fact_candidate.dim_person.person_id
            }
          )
        end

        it "updates the fact candidate status" do
          subject

          fact_candidate.reload
          expect(fact_candidate.status).to eq(JobOrders::CandidateStatus::SCREENED)
          expect(fact_candidate.terminal_status_at).to eq(nil)
        end
      end

      context "when the message is job_order_candidate_rescinded" do
        let(:message) do
          build(
            :message,
            stream_id: fact_candidate.dim_job_order.job_order_id,
            schema: JobOrders::Events::CandidateRescinded::V2,
            data: {
              person_id: fact_candidate.dim_person.person_id
            }
          )
        end

        it "updates the fact candidate status" do
          subject

          fact_candidate.reload
          expect(fact_candidate.status).to eq(JobOrders::CandidateStatus::RESCINDED)
          expect(fact_candidate.terminal_status_at).to eq(message.occurred_at)
        end
      end
    end

    context "when the message is job_created" do
      let(:message) do
        build(
          :message,
          schema: Events::JobCreated::V3,
          stream_id: job_id,
          data: {
            category: Job::Categories::MARKETPLACE,
            employment_title: "A title",
            employer_name: "An employer",
            employer_id: employer.employer_id,
            benefits_description: "Bad benifits",
            responsibilities_description: nil,
            location: "Columbus Ohio",
            employment_type: Job::EmploymentTypes::FULLTIME,
            hide_job:
          }
        )
      end

      let(:employer) { create(:analytics__dim_employer) }
      let(:job_id) { SecureRandom.uuid }
      let(:hide_job) { false }

      it "creates a dim job for the message" do
        expect { subject }.to change(Analytics::DimJob, :count).from(0).to(1)

        job = Analytics::DimJob.take(1).first

        expect(job.job_id).to eq(job_id)
        expect(job.category).to eq(message.data.category)
        expect(job.employment_title).to eq(message.data.employment_title)
        expect(job.employment_type).to eq(message.data.employment_type)
        expect(job.job_created_at).to eq(message.occurred_at)
        expect(job.employer_name).to eq(message.data.employer_name)
      end

      context "when the job was created hidden" do
        let(:hide_job) { true }

        it "does not create a job visibility fact" do
          expect { subject }.not_to change(Analytics::FactJobVisibility, :count)
        end
      end

      context "when the job was created visible" do
        let(:hide_job) { false }

        it "creates a job visibility fact" do
          expect { subject }.to change(Analytics::FactJobVisibility, :count).from(0).to(1)

          fact_job_visibility = Analytics::FactJobVisibility.take(1).first
          expect(fact_job_visibility.visible_starting_at).to eq(message.occurred_at)
        end
      end
    end

    context "when the message is job_updated" do
      let(:message) do
        build(
          :message,
          schema: Events::JobUpdated::V2,
          stream_id: job_id,
          data: {
            category: Job::Categories::STAFFING,
            employment_title: "Another title",
            employment_type: Job::EmploymentTypes::PARTTIME,
            hide_job:
          }
        )
      end

      let!(:dim_job) do
        create(
          :analytics__dim_job,
          job_id:
        )
      end
      let(:job_id) { SecureRandom.uuid }
      let(:hide_job) { nil }

      it "update a dim job from the message" do
        expect { subject }.not_to change(Analytics::DimJob, :count)

        job = Analytics::DimJob.take(1).first

        expect(job.category).to eq(message.data.category)
        expect(job.employment_title).to eq(message.data.employment_title)
        expect(job.employment_type).to eq(message.data.employment_type)
      end

      context "when the job visiblity wasn't specified" do
        let(:hide_job) { nil }

        it "does not create a job visibility fact" do
          expect { subject }.not_to change(Analytics::FactJobVisibility, :count)
        end
      end

      context "when the job was update to be hidden" do
        let(:hide_job) { true }

        context "when there is a job visiblity fact with nil ended_at" do
          let!(:fact_job_visibility) { create(:analytics__fact_job_visibility, dim_job:) }

          it "updates the job visibility fact" do
            expect { subject }.not_to change(Analytics::FactJobVisibility, :count)

            fact_job_visibility.reload
            expect(fact_job_visibility.visible_ending_at).to eq(message.occurred_at)
          end
        end

        context "when there isn't a job visiblity fact with nil ended_at" do
          let!(:fact_job_visibility) { create(:analytics__fact_job_visibility, :hidden, dim_job:) }

          it "does not updates the job visibility fact" do
            expect { subject }.not_to change(Analytics::FactJobVisibility, :count)

            fact_job_visibility.reload
            expect(fact_job_visibility.visible_ending_at).not_to eq(message.occurred_at)
          end
        end
      end

      context "when the job was update to be visible" do
        let(:hide_job) { false }

        context "when there is a job visiblity fact with nil ended_at" do
          let!(:fact_job_visibility) { create(:analytics__fact_job_visibility, dim_job:) }

          it "does not update the job visibility fact" do
            expect { subject }.not_to change(Analytics::FactJobVisibility, :count)

            fact_job_visibility.reload
            expect(fact_job_visibility.visible_ending_at).to eq(nil)
          end
        end

        context "when there isn't a job visiblity fact with nil ended_at" do
          let!(:fact_job_visibility) { create(:analytics__fact_job_visibility, :hidden, dim_job:) }

          it "creates a new job visibility fact with the new starting_at" do
            expect { subject }.to change(Analytics::FactJobVisibility, :count).from(1).to(2)

            new_fact_job_visibility = Analytics::FactJobVisibility.where.not(id: fact_job_visibility.id).take(1).first
            expect(new_fact_job_visibility.visible_starting_at).to eq(message.occurred_at)
          end
        end
      end
    end

    context "when the message is applicant_status_updated" do
      let(:message) do
        build(
          :message,
          schema: Events::ApplicantStatusUpdated::V6,
          stream_id: application_id,
          data: {
            applicant_first_name: "John",
            applicant_last_name: "Wexner",
            applicant_email: Faker::Internet.email,
            applicant_phone_number: Faker::PhoneNumber.phone_number,
            seeker_id:,
            user_id: SecureRandom.uuid,
            job_id:,
            employer_name: "An employers",
            employment_title: "Best job",
            status:
          },
          metadata: {}
        )
      end

      let!(:dim_job1) { create(:analytics__dim_job) }
      let!(:dim_job2) { create(:analytics__dim_job) }
      let!(:dim_job3) { create(:analytics__dim_job) }
      let!(:dim_person) do
        create(
          :analytics__dim_person,
          :seeker,
          person_id: seeker_id
        )
      end

      let(:application_id) { SecureRandom.uuid }
      let(:seeker_id) { SecureRandom.uuid }
      let(:job_id) { SecureRandom.uuid }
      let(:status) { ApplicantStatus::StatusTypes::NEW }

      context "If there isn't an existing application fact for the application id" do
        before do
          create(
            :analytics__fact_application,
            dim_job: dim_job1,
            dim_person:,
            application_number: 1
          )
          create(
            :analytics__fact_application,
            dim_job: dim_job2,
            dim_person:,
            application_number: 2
          )
        end

        let!(:dim_job) { create(:analytics__dim_job, job_id:) }

        it "creates a new application" do
          expect { subject }.to change(Analytics::FactApplication, :count).from(2).to(3)

          fact_application = Analytics::FactApplication.find_by!(application_id:)

          expect(fact_application.dim_job).to eq(dim_job)
          expect(fact_application.dim_person).to eq(dim_person)
          expect(fact_application.status).to eq(status)
          expect(fact_application.application_id).to eq(application_id)
          expect(fact_application.application_number).to eq(3)
          expect(fact_application.application_updated_at).to eq(message.occurred_at)
        end
      end

      context "If there is an existing application fact for the application id" do
        before do
          create(
            :analytics__fact_application,
            dim_job: dim_job1,
            dim_person:,
            application_id:,
            application_number: 1
          )
        end

        it "creates a new application" do
          expect { subject }.not_to change(Analytics::FactApplication, :count)

          fact_application = Analytics::FactApplication.find_by!(application_id:)

          expect(fact_application.status).to eq(status)
          expect(fact_application.application_updated_at).to eq(message.occurred_at)
        end
      end
    end

    context "when the message is seeker_viewed" do
      let(:message) do
        build(
          :message,
          schema: Events::PersonViewed::V1,
          stream_id: user_id,
          data: {
            person_id:
          }
        )
      end

      let(:user_id) { SecureRandom.uuid }
      let(:person_id) { SecureRandom.uuid }

      let!(:dim_user_viewer) { create(:analytics__dim_user, user_id:) }
      let!(:dim_person_viewed) { create(:analytics__dim_person, person_id:) }

      it "creates a fact person viewed record" do
        expect { subject }.to change(Analytics::FactPersonViewed, :count).from(0).to(1)

        fact_person_viewed = Analytics::FactPersonViewed.take

        expect(fact_person_viewed.dim_person_viewed).to eq(dim_person_viewed)
        expect(fact_person_viewed.dim_user_viewer).to eq(dim_user_viewer)
        expect(fact_person_viewed.viewed_at).to eq(message.occurred_at)
        expect(fact_person_viewed.viewing_context).to eq(Analytics::FactPersonViewed::Contexts::PUBLIC_PROFILE)
      end
    end

    context "when the message is person_viewed_in_coaching" do
      let(:message) do
        build(
          :message,
          schema: Events::PersonViewedInCoaching::V1,
          stream_id: coach_id,
          data: {
            person_id:
          }
        )
      end
      let(:coach_id) { SecureRandom.uuid }
      let!(:dim_coach_user) { create(:analytics__dim_user, coach_id:) }
      let(:person_id) { dim_person.person_id }
      let(:dim_person) { create(:analytics__dim_person) }

      it "creates a fact person viewed" do
        expect { subject }.to change(Analytics::FactPersonViewed, :count).from(0).to(1)

        fact_person_viewed = Analytics::FactPersonViewed.take

        expect(fact_person_viewed.dim_person_viewed).to eq(dim_person)
        expect(fact_person_viewed.dim_user_viewer).to eq(dim_coach_user)
        expect(fact_person_viewed.viewed_at).to eq(message.occurred_at)
        expect(fact_person_viewed.viewing_context).to eq(Analytics::FactPersonViewed::Contexts::COACHES_DASHBOARD)
      end
    end

    context "when the message is note_added" do
      let(:message) do
        build(
          :message,
          schema: Events::NoteAdded::V4,
          stream_id: dim_person_target.person_id,
          data: {
            originator: email,
            note: "Some note",
            note_id: SecureRandom.uuid
          }
        )
      end

      let(:email) { Faker::Internet.email }
      let(:person_id) { SecureRandom.uuid }

      let!(:dim_user_executor) { create(:analytics__dim_user, email:) }
      let!(:dim_person_target) { create(:analytics__dim_person, person_id:) }

      it "creates a fact coach action record" do
        expect { subject }.to change(Analytics::FactCoachAction, :count).from(0).to(1)

        fact_coach_action = Analytics::FactCoachAction.take(1).first

        expect(fact_coach_action.dim_user_executor).to eq(dim_user_executor)
        expect(fact_coach_action.dim_person_target).to eq(dim_person_target)
        expect(fact_coach_action.action_taken_at).to eq(message.occurred_at)
        expect(fact_coach_action.action).to eq(Analytics::FactCoachAction::Actions::NOTE_ADDED)
      end
    end

    context "when the message is note_modified" do
      let(:message) do
        build(
          :message,
          schema: Events::NoteModified::V4,
          stream_id: person_id,
          data: {
            originator: email,
            note: "Some note",
            note_id: SecureRandom.uuid
          }
        )
      end

      let(:email) { Faker::Internet.email }
      let(:person_id) { SecureRandom.uuid }

      let!(:dim_user_executor) { create(:analytics__dim_user, email:) }
      let!(:dim_person_target) { create(:analytics__dim_person, person_id:) }

      it "creates a fact coach action record" do
        expect { subject }.to change(Analytics::FactCoachAction, :count).from(0).to(1)

        fact_coach_action = Analytics::FactCoachAction.take(1).first

        expect(fact_coach_action.dim_user_executor).to eq(dim_user_executor)
        expect(fact_coach_action.dim_person_target).to eq(dim_person_target)
        expect(fact_coach_action.action_taken_at).to eq(message.occurred_at)
        expect(fact_coach_action.action).to eq(Analytics::FactCoachAction::Actions::NOTE_MODIFIED)
      end
    end

    context "when the message is note_deleted" do
      let(:message) do
        build(
          :message,
          schema: Events::NoteDeleted::V4,
          stream_id: person_id,
          data: {
            originator: email,
            note_id: SecureRandom.uuid
          }
        )
      end

      let(:email) { Faker::Internet.email }
      let(:person_id) { SecureRandom.uuid }

      let!(:dim_user_executor) { create(:analytics__dim_user, email:) }
      let!(:dim_person_target) { create(:analytics__dim_person, person_id:) }

      it "creates a fact coach action record" do
        expect { subject }.to change(Analytics::FactCoachAction, :count).from(0).to(1)

        fact_coach_action = Analytics::FactCoachAction.take(1).first

        expect(fact_coach_action.dim_user_executor).to eq(dim_user_executor)
        expect(fact_coach_action.dim_person_target).to eq(dim_person_target)
        expect(fact_coach_action.action_taken_at).to eq(message.occurred_at)
        expect(fact_coach_action.action).to eq(Analytics::FactCoachAction::Actions::NOTE_DELETED)
      end
    end

    context "when the message is job_recommended" do
      let(:message) do
        build(
          :message,
          schema: Events::JobRecommended::V3,
          stream_id: person_id,
          data: {
            job_id: SecureRandom.uuid,
            coach_id:
          }
        )
      end

      let(:coach_id) { SecureRandom.uuid }
      let(:person_id) { SecureRandom.uuid }

      let!(:dim_user_executor) { create(:analytics__dim_user, coach_id:) }
      let!(:dim_person_target) { create(:analytics__dim_person, person_id:) }

      it "creates a fact coach action record" do
        expect { subject }.to change(Analytics::FactCoachAction, :count).from(0).to(1)

        fact_coach_action = Analytics::FactCoachAction.take(1).first

        expect(fact_coach_action.dim_user_executor).to eq(dim_user_executor)
        expect(fact_coach_action.dim_person_target).to eq(dim_person_target)
        expect(fact_coach_action.action_taken_at).to eq(message.occurred_at)
        expect(fact_coach_action.action).to eq(Analytics::FactCoachAction::Actions::JOB_RECOMMENDED)
      end
    end

    context "when the message is person certified" do
      let(:message) do
        build(
          :message,
          schema: Events::PersonCertified::V1,
          stream_id: person_id,
          data: {
            coach_email: Faker::Internet.email,
            coach_first_name: "John",
            coach_last_name: "E-Boy C",
            coach_id:
          }
        )
      end

      let(:coach_id) { SecureRandom.uuid }
      let(:person_id) { SecureRandom.uuid }

      let!(:dim_user_executor) { create(:analytics__dim_user, coach_id:) }
      let!(:dim_person_target) { create(:analytics__dim_person, person_id:) }

      it "creates a fact coach action record" do
        expect { subject }.to change(Analytics::FactCoachAction, :count).from(0).to(1)

        fact_coach_action = Analytics::FactCoachAction.take(1).first

        expect(fact_coach_action.dim_user_executor).to eq(dim_user_executor)
        expect(fact_coach_action.dim_person_target).to eq(dim_person_target)
        expect(fact_coach_action.action_taken_at).to eq(message.occurred_at)
        expect(fact_coach_action.action).to eq(Analytics::FactCoachAction::Actions::SEEKER_CERTIFIED)
      end
    end
  end
end

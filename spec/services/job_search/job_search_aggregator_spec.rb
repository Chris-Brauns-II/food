require 'rails_helper'

RSpec.describe JobSearch::JobSearchAggregator do
  let(:consumer) { described_class.new }
  let(:id) { SecureRandom.uuid }

  it_behaves_like "a replayable message consumer"

  describe "#handle_message" do
    subject do
      consumer.handle_message(message)
    end

    before do
      messages.each do |message|
        Event.from_message!(message)
      end
    end

    let(:messages) { [] }

    context "when message is employer created" do
      let(:message) do
        build(
          :message,
          stream_id: SecureRandom.uuid,
          schema: Events::EmployerCreated::V1,
          data: {
            name: "Employer",
            location: "Columbus",
            bio: "Bro",
            logo_url: "www.google.com"
          }
        )
      end

      it "creates an employer" do
        expect { subject }.to change(JobSearch::Employer, :count).from(0).to(1)

        employer = JobSearch::Employer.first
        expect(employer.id).to eq(message.stream.id)
        expect(employer.logo_url).to eq(message.data.logo_url)
      end
    end

    context "when the message needs an employer" do
      let!(:employer) { create(:job_search__employer) }

      context "when the message is employer updated" do
        let(:message) do
          build(
            :message,
            stream_id: employer.id,
            schema: Events::EmployerUpdated::V1,
            data: {
              name: "Employer",
              location: "Columbus",
              bio: "Bro",
              logo_url: "www.skillarc.com"
            }
          )
        end

        let!(:job) { create(:job_search__job, employer_id: employer.id) }

        it "updates an employer and associated jobs" do
          subject

          employer.reload
          expect(employer.logo_url).to eq(message.data.logo_url)

          job.reload
          expect(job.employer_logo_url).to eq(message.data.logo_url)
        end
      end

      context "when the message is job created" do
        let(:message) do
          build(
            :message,
            schema: Events::JobCreated::V3,
            stream_id: SecureRandom.uuid,
            data: {
              category: Job::Categories::STAFFING,
              employment_title: "Plumber",
              employer_name: "Good Employer",
              employer_id: employer.id,
              benefits_description: "Great Benifits",
              location: "Columbus, OH",
              employment_type: Job::EmploymentTypes::FULLTIME,
              hide_job: false,
              industry: nil
            }
          )
        end

        it "creates a job" do
          expect { subject }.to change(JobSearch::Job, :count).from(0).to(1)

          job = JobSearch::Job.first

          expect(job.category).to eq(message.data.category)
          expect(job.employer_logo_url).to eq(employer.logo_url)
          expect(job.employment_title).to eq(message.data.employment_title)
          expect(job.employment_type).to eq(message.data.employment_type)
          expect(job.employer_name).to eq(message.data.employer_name)
          expect(job.hidden).to eq(message.data.hide_job)
          expect(job.location).to eq(message.data.location)
          expect(job.industries).to eq(message.data.industry)
          expect(job.job_id).to eq(message.stream.id)
          expect(job.employer_id).to eq(message.data.employer_id)
        end
      end
    end

    context "when the message needs a job" do
      let!(:job) { create(:job_search__job) }

      context "when the message is job updated" do
        let(:message) do
          build(
            :message,
            stream_id: job.job_id,
            schema: Events::JobUpdated::V2,
            data: {
              category: Job::Categories::MARKETPLACE,
              employment_title: "Senior Plumber",
              benefits_description: "Great Benifits",
              location: "Columbus, OH",
              employment_type: Job::EmploymentTypes::FULLTIME,
              hide_job: false,
              industry: nil
            }
          )
        end

        it "updates a job" do
          subject

          job.reload
          expect(job.category).to eq(message.data.category)
          expect(job.employment_title).to eq(message.data.employment_title)
          expect(job.employment_type).to eq(message.data.employment_type)
          expect(job.hidden).to eq(message.data.hide_job)
          expect(job.location).to eq(message.data.location)
          expect(job.industries).to eq(message.data.industry)
        end
      end

      context "when a job tag is needed" do
        let(:messages) do
          [
            build(
              :message,
              stream_id: tag_id,
              schema: Events::TagCreated::V1,
              data: {
                name: "Cool"
              }
            )
          ]
        end

        context "when the message is job tag created" do
          let(:message) do
            build(
              :message,
              stream_id: job.job_id,
              schema: Events::JobTagCreated::V1,
              data: {
                id: SecureRandom.uuid,
                job_id: job.job_id,
                tag_id:
              }
            )
          end

          let(:tag_id) { SecureRandom.uuid }
          let!(:job) { create(:job_search__job, tags: []) }

          it "updates the tags on the job" do
            subject

            job.reload
            expect(job.tags).to eq(["Cool"])
          end
        end

        context "when the message is job tag destroyed" do
          let(:message) do
            build(
              :message,
              stream_id: job.job_id,
              schema: Events::JobTagDestroyed::V2,
              data: {
                job_tag_id: SecureRandom.uuid,
                job_id: job.job_id,
                tag_id:
              }
            )
          end

          let(:tag_id) { SecureRandom.uuid }
          let!(:job) { create(:job_search__job, tags: ["Cool"]) }

          it "updates the tags on the job" do
            subject

            job.reload
            expect(job.tags).to eq([])
          end
        end
      end

      context "when needing the career path projection" do
        before do
          allow_any_instance_of(Jobs::Projectors::CareerPaths)
            .to receive(:project)
            .and_return(career_paths)
        end

        let(:career_paths) do
          Jobs::Projectors::CareerPaths::Projection.new(
            paths: [
              Jobs::Projectors::CareerPaths::Path.new(
                id: SecureRandom.uuid,
                title: "Title",
                order: 0,
                lower_limit: "15000",
                upper_limit: "24000"
              )
            ]
          )
        end

        context 'when the message is career path created' do
          let(:career_paths_created_for_job1) do
            build(
              :message,
              stream_id: job.id,
              schema: Events::CareerPathCreated::V1,
              data: {
                id: SecureRandom.uuid,
                job_id: job.id,
                title: "Entry Level",
                lower_limit: "17000",
                upper_limit: "23000",
                order: 0
              }
            )

            it "updates the job pay to the projection result" do
              subject

              job.reload
              expect(job.starting_lower_pay).to eq(15_000)
              expect(job.starting_upper_pay).to eq(24_000)
            end
          end
        end

        context 'when the message is career path updated' do
          let(:career_paths_created_for_job1) do
            build(
              :message,
              stream_id: job.id,
              schema: Events::CareerPathUpdated::V1,
              data: {
                id: SecureRandom.uuid,
                order: 0
              }
            )

            it "updates the job pay to the projection result" do
              subject

              job.reload
              expect(job.starting_lower_pay).to eq(15_000)
              expect(job.starting_upper_pay).to eq(24_000)
            end
          end
        end
      end

      context "when the message is applicant status updated" do
        let(:message) do
          build(
            :message,
            stream_id: application_id,
            schema: Events::ApplicantStatusUpdated::V6,
            data: {
              applicant_first_name: "John",
              applicant_last_name: "Chabot",
              applicant_email: "john@skillarc.com",
              seeker_id: SecureRandom.uuid,
              user_id: SecureRandom.uuid,
              job_id: job.job_id,
              employer_name: "Good Employer",
              employment_title: "Plumber",
              status: ApplicantStatus::StatusTypes::INTERVIEWING
            },
            metadata: {
              user_id: SecureRandom.uuid
            }
          )
        end

        let(:application_id) { SecureRandom.uuid }

        context "when the application exists" do
          let!(:application) { create(:job_search__application, application_id:, search_job: job) }

          it "updates the application" do
            expect { subject }.not_to change(JobSearch::Application, :count)

            application.reload

            expect(application.seeker_id).to eq(message.data.seeker_id)
            expect(application.status).to eq(message.data.status)
            expect(application.job_id).to eq(message.data.job_id)
          end
        end

        context "when the application does not exists" do
          it "creates and application" do
            expect { subject }.to change(JobSearch::Application, :count).from(0).to(1)

            application = JobSearch::Application.first

            expect(application.application_id).to eq(application_id)
            expect(application.seeker_id).to eq(message.data.seeker_id)
            expect(application.status).to eq(message.data.status)
            expect(application.search_job_id).to eq(job.id)
            expect(application.job_id).to eq(message.data.job_id)
          end
        end
      end

      context "when the message is elevator pitch created" do
        let(:message) do
          build(
            :message,
            stream_id: seeker_id,
            schema: Events::ElevatorPitchCreated::V2,
            data: {
              job_id:,
              pitch: "I'm going to be the very best"
            }
          )
        end

        let(:seeker_id) { SecureRandom.uuid }
        let(:job_id) { job.job_id }

        let!(:application) { create(:job_search__application, seeker_id:, job_id:) }

        it "updates the application" do
          subject

          application.reload
          expect(application.elevator_pitch).to eq(message.data.pitch)
        end
      end

      context "when the message is job saved" do
        let(:message) do
          build(
            :message,
            stream_id: SecureRandom.uuid,
            schema: Events::JobSaved::V1,
            data: {
              job_id: job.job_id,
              employment_title: "A Job",
              employer_name: "Employer"
            }
          )
        end

        let(:job_id) { SecureRandom.uuid }

        it "creates a saved job record" do
          expect { subject }.to change(JobSearch::SavedJob, :count).from(0).to(1)

          saved_job = JobSearch::SavedJob.first
          expect(saved_job.search_job).to eq(job)
          expect(saved_job.user_id).to eq(message.stream.id)
        end
      end

      context "when the message is job unsaved" do
        let(:message) do
          build(
            :message,
            stream_id: user_id,
            schema: Events::JobUnsaved::V1,
            data: {
              job_id: job.job_id,
              employment_title: "A Job",
              employer_name: "Employer"
            }
          )
        end

        let(:user_id) { SecureRandom.uuid }
        let!(:saved_job) { create(:job_search__saved_job, search_job: job, user_id:) }

        it "updates the application" do
          expect { subject }.to change(JobSearch::SavedJob, :count).from(1).to(0)
        end
      end
    end
  end
end

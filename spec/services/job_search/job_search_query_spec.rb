require 'rails_helper'

RSpec.describe JobSearch::JobSearchQuery do
  describe "#search" do
    subject do
      instance.search(
        search_terms:,
        industries:,
        tags:,
        user:,
        utm_source:
      )
    end

    let(:instance) { described_class.new(message_service:) }
    let(:message_service) { MessageService.new }

    let(:search_terms) { nil }
    let(:industries) { nil }
    let(:tags) { nil }
    let(:user) { nil }
    let(:utm_source) { nil }

    let(:applicant_id1) { "bbd92d61-8367-46e0-aafe-89369df95eba" }
    let(:applicant_id2) { "b3f5fe09-e227-4d2a-b47a-bba51b33c23b" }
    let(:job_id1) { "516efc70-a246-4692-9b61-5321dcd2291b" }
    let(:job_id2) { "d2104dff-f8eb-4122-acdb-48369b0ecc4e" }
    let(:job_id3) { "f20f2134-fea2-46bd-a280-004e0f41a045" }
    let(:user_id1) { "f24fd7b6-e4ca-441e-b207-f3ad8684a02b" }
    let(:user_id2) { "915816cb-4ea9-4a6e-b48d-5162ce12f786" }
    let(:seeker_id1) { "6c535506-3289-4ffe-9767-a258f760de35" }
    let(:seeker_id2) { "6ec7a915-12cf-46a6-bca9-ca25599e73cd" }

    let(:employer_id1) { SecureRandom.uuid }
    let(:employer_id2) { SecureRandom.uuid }

    let(:tag_id1) { SecureRandom.uuid }
    let(:tag_id2) { SecureRandom.uuid }

    let!(:job1) do
      create(
        :job_search__job,
        category: Job::Categories::MARKETPLACE,
        job_id: job_id1,
        employment_title: "Senior Plumber",
        industries: nil,
        location: "Columbus, OH",
        starting_lower_pay: 17_000,
        starting_upper_pay: 23_000,
        tags: ["Tag1"],
        employer_id: employer_id1,
        employer_name: "Good Employer",
        employer_logo_url: "www.google.com"
      )
    end
    let!(:job2) do
      create(
        :job_search__job,
        category: Job::Categories::STAFFING,
        job_id: job_id2,
        employment_title: "Mechanic",
        industries: [Job::Industries::CONSTRUCTION, Job::Industries::MANUFACTURING],
        location: "Columbus, OH",
        starting_lower_pay: 10,
        starting_upper_pay: 15,
        tags: ["Tag2"],
        employer_id: employer_id2,
        employer_name: "Joe's Mechanic's shop",
        employer_logo_url: "www.yahoo.com"
      )
    end
    let!(:job3) do
      create(
        :job_search__job,
        category: Job::Categories::MARKETPLACE,
        job_id: job_id3,
        employment_title: "Silly Job",
        industries: [Job::Industries::LOGISTICS],
        location: "Columbus, OH",
        starting_lower_pay: nil,
        starting_upper_pay: nil,
        tags: [],
        employer_id: employer_id1,
        employer_name: "Good Employer",
        employer_logo_url: "www.google.com"
      )
    end

    let(:expected_job1_no_user) do
      {
        id: job_id1,
        category: Job::Categories::MARKETPLACE,
        employment_title: "Senior Plumber",
        industries: nil,
        location: "Columbus, OH",
        starting_pay: {
          employment_type: "salary",
          lower_limit: 17_000,
          upper_limit: 23_000
        },
        tags: ["Tag1"],
        application_status: nil,
        elevator_pitch: nil,
        saved: nil,
        employer: {
          id: employer_id1,
          name: "Good Employer",
          logo_url: "www.google.com"
        }
      }
    end
    let(:expected_job2_no_user) do
      {
        id: job_id2,
        category: Job::Categories::STAFFING,
        employment_title: "Mechanic",
        industries: [Job::Industries::CONSTRUCTION, Job::Industries::MANUFACTURING],
        location: "Columbus, OH",
        starting_pay: {
          employment_type: "hourly",
          lower_limit: 10,
          upper_limit: 15
        },
        tags: %w[Tag2],
        application_status: nil,
        elevator_pitch: nil,
        saved: nil,
        employer: {
          id: employer_id2,
          name: "Joe's Mechanic's shop",
          logo_url: "www.yahoo.com"
        }
      }
    end
    let(:expected_job3_no_user) do
      {
        id: job_id3,
        category: Job::Categories::MARKETPLACE,
        employment_title: "Silly Job",
        industries: [Job::Industries::LOGISTICS],
        location: "Columbus, OH",
        starting_pay: nil,
        tags: [],
        application_status: nil,
        elevator_pitch: nil,
        saved: nil,
        employer: {
          id: employer_id1,
          name: "Good Employer",
          logo_url: "www.google.com"
        }
      }
    end

    context "search source" do
      context "when user is nil" do
        it "emits a search event for unauthenticated" do
          expect(message_service)
            .to receive(:create!)
            .with(
              schema: Events::JobSearch::V2,
              data: {
                search_terms:,
                industries:,
                tags:
              },
              search_id: 'unauthenticated',
              metadata: {
                source: "unauthenticated",
                utm_source:
              }
            )

          subject
        end
      end

      context "when user doesn't have a seeker" do
        let(:user) { create(:user) }

        it "emits a search event for a non-seeker" do
          expect(message_service)
            .to receive(:create!)
            .with(
              schema: Events::JobSearch::V2,
              data: {
                search_terms:,
                industries:,
                tags:
              },
              search_id: user.id,
              metadata: {
                source: "user",
                id: user.id,
                utm_source:
              }
            )

          subject
        end
      end

      context "when user does have a seeker" do
        let(:user) { create(:user) }
        let!(:seeker) { create(:seeker, user_id: user.id) }

        it "emits a search event for a non-seeker" do
          expect(message_service)
            .to receive(:create!)
            .with(
              schema: Events::JobSearch::V2,
              data: {
                search_terms:,
                industries:,
                tags:
              },
              search_id: user.id,
              metadata: {
                source: "seeker",
                id: user.id,
                utm_source:
              }
            )

          subject
        end
      end
    end

    context "when no constraints are provided" do
      context "when no user is provided" do
        it "returns all jobs" do
          expect(subject[0]).to eq(expected_job2_no_user)
          expect(subject).to contain_exactly(expected_job2_no_user, expected_job3_no_user, expected_job1_no_user)
        end
      end

      context "when user is provided" do
        before do
          create(:job_search__saved_job, search_job: job1, user_id: user.id)
        end

        let(:user) { create(:user, id: user_id1) }

        it "returns all jobs with saved jobs" do
          expected_result = [
            {
              id: job_id2,
              category: Job::Categories::STAFFING,
              employment_title: "Mechanic",
              industries: [Job::Industries::CONSTRUCTION, Job::Industries::MANUFACTURING],
              location: "Columbus, OH",
              starting_pay: {
                employment_type: "hourly",
                lower_limit: 10,
                upper_limit: 15
              },
              tags: %w[Tag2],
              application_status: nil,
              elevator_pitch: nil,
              saved: false,
              employer: {
                id: employer_id2,
                name: "Joe's Mechanic's shop",
                logo_url: "www.yahoo.com"
              }
            },
            {
              id: job_id3,
              category: Job::Categories::MARKETPLACE,
              employment_title: "Silly Job",
              industries: [Job::Industries::LOGISTICS],
              location: "Columbus, OH",
              starting_pay: nil,
              tags: [],
              application_status: nil,
              elevator_pitch: nil,
              saved: false,
              employer: {
                id: employer_id1,
                name: "Good Employer",
                logo_url: "www.google.com"
              }
            },
            {
              id: job_id1,
              category: Job::Categories::MARKETPLACE,
              employment_title: "Senior Plumber",
              industries: nil,
              location: "Columbus, OH",
              starting_pay: {
                employment_type: "salary",
                lower_limit: 17_000,
                upper_limit: 23_000
              },
              tags: ["Tag1"],
              application_status: nil,
              elevator_pitch: nil,
              saved: true,
              employer: {
                id: employer_id1,
                name: "Good Employer",
                logo_url: "www.google.com"
              }
            }
          ]

          expect(subject[0]).to eq(expected_result[0])
          expect(subject).to contain_exactly(*expected_result)
        end
      end

      context "when user with a seeker is provided" do
        before do
          create(:job_search__saved_job, search_job: job1, user_id: user.id)
          create(:job_search__application, search_job: job2, seeker_id: seeker.id, status: "interviewing", elevator_pitch: "I'm going to be the very best")
        end

        let(:user) { create(:user, id: user_id1) }
        let!(:seeker) { create(:seeker, id: seeker_id2, user_id: user.id) }

        it "returns all jobs with saved jobs" do
          expected_result = [
            {
              id: job_id2,
              category: Job::Categories::STAFFING,
              employment_title: "Mechanic",
              industries: [Job::Industries::CONSTRUCTION, Job::Industries::MANUFACTURING],
              location: "Columbus, OH",
              starting_pay: {
                employment_type: "hourly",
                lower_limit: 10,
                upper_limit: 15
              },
              tags: %w[Tag2],
              application_status: "interviewing",
              elevator_pitch: "I'm going to be the very best",
              saved: false,
              employer: {
                id: employer_id2,
                name: "Joe's Mechanic's shop",
                logo_url: "www.yahoo.com"
              }
            },
            {
              id: job_id3,
              category: Job::Categories::MARKETPLACE,
              employment_title: "Silly Job",
              industries: [Job::Industries::LOGISTICS],
              location: "Columbus, OH",
              starting_pay: nil,
              tags: [],
              application_status: nil,
              elevator_pitch: nil,
              saved: false,
              employer: {
                id: employer_id1,
                name: "Good Employer",
                logo_url: "www.google.com"
              }
            },
            {
              id: job_id1,
              category: Job::Categories::MARKETPLACE,
              employment_title: "Senior Plumber",
              industries: nil,
              location: "Columbus, OH",
              starting_pay: {
                employment_type: "salary",
                lower_limit: 17_000,
                upper_limit: 23_000
              },
              tags: ["Tag1"],
              application_status: nil,
              elevator_pitch: nil,
              saved: true,
              employer: {
                id: employer_id1,
                name: "Good Employer",
                logo_url: "www.google.com"
              }
            }
          ]

          expect(subject[0]).to eq(expected_result[0])
          expect(subject).to contain_exactly(*expected_result)
        end
      end
    end

    context "when search terms are provided" do
      context "when the search terms doesn't match anything" do
        let(:search_terms) { "Zoo Person" }

        it "returns all no jobs" do
          expect(subject).to eq([])
        end
      end

      context "when the search terms is less than three characters" do
        let(:search_terms) { "a" }

        it "is ignored and returns all jobs" do
          expect(subject[0]).to eq(expected_job2_no_user)
          expect(subject).to contain_exactly(expected_job2_no_user, expected_job3_no_user, expected_job1_no_user)
        end
      end

      context "when the search terms match a job" do
        let(:search_terms) { "Plumber" }

        it "returns all no jobs" do
          expect(subject).to eq([expected_job1_no_user])
        end
      end

      context "when the search terms case insenstive match a job" do
        let(:search_terms) { "plumber" }

        it "returns all no jobs" do
          expect(subject).to eq([expected_job1_no_user])
        end
      end

      context "when the search terms case insenstive match an employer" do
        let(:search_terms) { "Joe" }

        it "returns all no jobs" do
          expect(subject).to eq([expected_job2_no_user])
        end
      end
    end

    context "when industries are provided" do
      context "when industries don't match anything" do
        let(:industries) { ["Poker"] }

        it "returns all no jobs" do
          expect(subject).to eq([])
        end
      end

      context "When there is overlap with industries" do
        let(:industries) { [Job::Industries::CONSTRUCTION, Job::Industries::LOGISTICS] }

        it "returns all jobs with overlapping industries" do
          expect(subject).to eq([expected_job2_no_user, expected_job3_no_user])
        end
      end
    end

    context "when tags are provided" do
      context "when tags don't match anything" do
        let(:tags) { ["Certified Lame"] }

        it "returns all no jobs" do
          expect(subject).to eq([])
        end
      end

      context "When there is overlap with industries" do
        let(:tags) { %w[Tag3 Tag2] }

        it "all jobs with overlapping tags" do
          expect(subject).to eq([expected_job2_no_user])
        end
      end
    end

    context "when everything is used" do
      let(:search_terms) { "Joe" }
      let(:industries) { [Job::Industries::CONSTRUCTION] }
      let(:tags) { ["Tag2"] }

      it "returns the matching job" do
        expect(subject).to eq([expected_job2_no_user])
      end
    end
  end
end

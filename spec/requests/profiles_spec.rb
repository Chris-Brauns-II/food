require 'rails_helper'
require 'swagger_helper'

RSpec.describe "Profiles", type: :request do
  path "/profiles/{id}" do
    get "Retrieve a seeker" do
      tags 'Seekers'
      produces 'application/json'
      security [bearer_auth: []]
      parameter name: :id, in: :path, type: :string

      include_context "olive branch casing parameter"
      include_context "olive branch camelcasing"

      let(:id) { seeker.id }
      let(:seeker) { create(:seeker) }

      response '404', 'Seeker not found' do
        include_context "unauthenticated openapi"

        let(:id) { SecureRandom.uuid }

        run_test!
      end

      response '200', 'profiles retrieved' do
        schema "$ref" => "#/components/schemas/seeker"

        context "when unauthticated" do
          include_context "unauthenticated openapi"

          before do
            expect_any_instance_of(SeekerService)
              .to receive(:get)
              .with(user_id: nil, seeker_editor: false)
              .and_call_original
          end

          context "when seeker is empty" do
            let(:seeker) { create(:seeker) }

            run_test!
          end

          context "when seeker is fully specified" do
            before do
              create(:education_experience, seeker:)
              create(:other_experience, seeker:)
              create(:personal_experience, seeker:)
              create(:profile_skill, seeker:)
              create(:reference, author_profile_id: create(:training_provider_profile).id, seeker_id: seeker.id)
              create(:seeker_training_provider, seeker_id: seeker.id)
            end

            let(:seeker) { create(:seeker) }

            run_test!
          end
        end

        context "when authenticated" do
          context "when the user is the seeker" do
            include_context "authenticated openapi"

            before do
              expect_any_instance_of(SeekerService)
                .to receive(:get)
                .with(user_id: user.id, seeker_editor: true)
                .and_call_original
            end

            context "when seeker is empty" do
              let(:seeker) { create(:seeker, user_id: user.id) }

              run_test!
            end

            context "when seeker is fully specified" do
              before do
                create(:education_experience, seeker:)
                create(:other_experience, seeker:)
                create(:personal_experience, seeker:)
                create(:profile_skill, seeker:)
                create(:reference, author_profile_id: create(:training_provider_profile).id, seeker_id: seeker.id)
                create(:seeker_training_provider, seeker_id: seeker.id)
              end

              let(:seeker) { create(:seeker, user_id: user.id) }

              run_test!
            end
          end

          context "when the user is a coach" do
            include_context "coach authenticated openapi"

            before do
              expect_any_instance_of(SeekerService)
                .to receive(:get)
                .with(user_id: user.id, seeker_editor: true)
                .and_call_original
            end

            context "when seeker is empty" do
              let(:seeker) { create(:seeker) }

              run_test!
            end

            context "when seeker is fully specified" do
              before do
                create(:education_experience, seeker:)
                create(:other_experience, seeker:)
                create(:personal_experience, seeker:)
                create(:profile_skill, seeker:)
                create(:reference, author_profile_id: create(:training_provider_profile).id, seeker_id: seeker.id)
                create(:seeker_training_provider, seeker_id: seeker.id)
              end

              let(:seeker) { create(:seeker) }

              run_test!
            end
          end
        end
      end
    end
  end
end

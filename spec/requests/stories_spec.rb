require 'rails_helper'
require 'swagger_helper'

RSpec.describe "Stories", type: :request do
  let(:seeker) { create(:seeker, user_id: user_to_edit.id) }
  let(:user_to_edit) { create(:user) }

  path '/profiles/{profile_id}/stories/{story_id}' do
    delete 'Deletes a story' do
      tags 'Seekers'
      consumes 'application/json'
      produces 'application/json'
      security [bearer_auth: []]
      parameter name: :profile_id, in: :path, type: :string, format: :uuid
      parameter name: :story_id, in: :path, type: :string, format: :uuid

      include_context "olive branch casing parameter"
      include_context "olive branch camelcasing"

      let(:profile_id) { seeker.id }
      let(:story_id) { story.id }
      let(:story) { create(:story, seeker:) }

      it_behaves_like "seeker spec unauthenticated openapi"

      context "when authenticated" do
        include_context "profile owner openapi"

        response '202', 'story deleted' do
          before do
            expect(Seekers::StoriesService).to receive(:new).with(seeker).and_call_original

            expect_any_instance_of(Seekers::StoriesService).to receive(:destroy).with(story:).and_call_original
          end

          run_test!
        end
      end
    end
  end

  path '/profiles/{profile_id}/stories/{story_id}' do
    put 'Updates a story' do
      tags 'Seekers'
      consumes 'application/json'
      produces 'application/json'
      security [bearer_auth: []]
      parameter name: :profile_id, in: :path, type: :string, format: :uuid
      parameter name: :story_id, in: :path, type: :string, format: :uuid
      parameter name: :update_params, in: :body, schema: {
        type: :object,
        properties: {
          story: {
            type: :object,
            required: %w[prompt response],
            properties: {
              prompt: {
                type: :string
              },
              response: {
                type: :string
              }
            }
          }
        },
        required: %w[story]
      }

      include_context "olive branch casing parameter"
      include_context "olive branch camelcasing"

      let(:profile_id) { seeker.id }
      let(:story_id) { story.id }
      let(:story) { create(:story, seeker:) }
      let(:update_params) do
        {
          story: {
            prompt: "This is a new prompt",
            response: "This is a response"
          }
        }
      end

      it_behaves_like "seeker spec unauthenticated openapi"

      context "when authenticated" do
        include_context "profile owner openapi"

        response '202', 'story updated' do
          before do
            expect(Seekers::StoriesService).to receive(:new).with(seeker).and_call_original

            expect_any_instance_of(Seekers::StoriesService).to receive(:update).with(
              story:,
              prompt: "This is a new prompt",
              response: "This is a response"
            ).and_call_original
          end

          run_test!
        end
      end
    end
  end

  path '/profiles/{profile_id}/stories' do
    post 'Creates a story' do
      tags 'Seekers'
      consumes 'application/json'
      produces 'application/json'
      security [bearer_auth: []]
      parameter name: :profile_id, in: :path, type: :string, format: :uuid
      parameter name: :create_params, in: :body, schema: {
        type: :object,
        properties: {
          story: {
            type: :object,
            required: %w[prompt response],
            properties: {
              prompt: {
                type: :string
              },
              response: {
                type: :string
              }
            }
          }
        },
        required: %w[story]
      }

      include_context "olive branch casing parameter"
      include_context "olive branch camelcasing"

      let(:profile_id) { seeker.id }
      let(:create_params) do
        {
          story: {
            prompt: "This is a prompt",
            response: "This is a response"
          }
        }
      end

      it_behaves_like "seeker spec unauthenticated openapi"

      context "when authenticated" do
        include_context "profile owner openapi"

        response '201', 'story created' do
          before do
            expect(Seekers::StoriesService).to receive(:new).with(seeker).and_call_original

            expect_any_instance_of(Seekers::StoriesService).to receive(:create).with(
              prompt: "This is a prompt",
              response: "This is a response"
            ).and_call_original
          end

          run_test!
        end
      end
    end
  end
end

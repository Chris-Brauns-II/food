require 'rails_helper'
require 'swagger_helper'

RSpec.describe "Skills", type: :request do
  let(:master_skill) { create(:master_skill) }
  let(:seeker) { create(:seeker, user_id: user_to_edit.id) }
  let(:user_to_edit) { create(:user) }

  path '/profiles/{profile_id}/skills' do
    post 'Creates a skill' do
      tags 'Seekers'
      consumes 'application/json'
      produces 'application/json'
      security [bearer_auth: []]
      parameter name: :profile_id, in: :path, type: :string, format: :uuid
      parameter name: :create_params, in: :body, schema: {
        type: :object,
        properties: {
          skill: {
            type: :object,
            required: %w[master_skill_id],
            properties: {
              masterSkillId: {
                type: :string,
                format: :uuid
              },
              description: {
                type: :string
              }
            }
          }
        },
        required: %w[skill]
      }

      include_context "olive branch casing parameter"
      include_context "olive branch camelcasing"

      let(:profile_id) { seeker.id }
      let(:create_params) do
        {
          skill: {
            masterSkillId: master_skill.id,
            description: "This is a description"
          }
        }
      end
      let(:master_skill) { create(:master_skill) }

      it_behaves_like "seeker spec unauthenticated openapi"

      context "when authenticated" do
        include_context "profile owner openapi"

        response '201', 'skill created' do
          before do
            expect(Seekers::SkillService)
              .to receive(:new)
              .with(seeker)
              .and_call_original

            expect_any_instance_of(Seekers::SkillService)
              .to receive(:create)
              .with(master_skill_id: master_skill.id, description: "This is a description")
              .and_call_original
          end

          run_test!
        end
      end
    end
  end

  path '/profiles/{profile_id}/skills/{id}' do
    put 'Updates a skill' do
      tags 'Seekers'
      consumes 'application/json'
      produces 'application/json'
      security [bearer_auth: []]

      parameter name: :profile_id, in: :path, type: :string, format: :uuid
      parameter name: :id, in: :path, type: :string, format: :uuid

      parameter name: :update_params, in: :body, schema: {
        type: :object,
        properties: {
          skill: {
            type: :object,
            required: %w[description],
            properties: {
              description: {
                type: :string
              }
            }
          }
        },
        required: %w[skill]
      }

      include_context "olive branch casing parameter"
      include_context "olive branch camelcasing"

      let(:profile_id) { seeker.id }
      let(:id) { skill.id }

      let(:skill) { create(:profile_skill, seeker:) }

      let(:update_params) do
        {
          skill: {
            description: "This is a new description"
          }
        }
      end

      it_behaves_like "seeker spec unauthenticated openapi"

      context "when authenticated" do
        include_context "profile owner openapi"

        response '202', 'skill updated' do
          before do
            expect(Seekers::SkillService)
              .to receive(:new)
              .with(seeker)
              .and_call_original

            expect_any_instance_of(Seekers::SkillService)
              .to receive(:update)
              .with(skill, description: "This is a new description")
              .and_call_original
          end

          run_test!
        end
      end
    end

    delete 'Deletes a skill' do
      tags 'Seekers'
      consumes 'application/json'
      produces 'application/json'
      security [bearer_auth: []]

      parameter name: :profile_id, in: :path, type: :string, format: :uuid
      parameter name: :id, in: :path, type: :string, format: :uuid

      include_context "olive branch casing parameter"
      include_context "olive branch camelcasing"

      let(:profile_id) { seeker.id }
      let(:id) { skill.id }

      let(:skill) { create(:profile_skill, seeker:) }

      it_behaves_like "seeker spec unauthenticated openapi"

      context "when authenticated" do
        include_context "profile owner openapi"

        response '202', 'skill destroyed' do
          before do
            expect(Seekers::SkillService)
              .to receive(:new)
              .with(seeker)
              .and_call_original

            expect_any_instance_of(Seekers::SkillService)
              .to receive(:destroy)
              .with(skill)
              .and_call_original
          end

          run_test!
        end
      end
    end
  end
end

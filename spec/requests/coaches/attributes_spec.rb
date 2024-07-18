require 'rails_helper'
require 'swagger_helper'

RSpec.describe "Attributes", type: :request do
  path '/coaches/attributes' do
    get "Get all attributes" do
      tags 'Coaches'
      produces 'application/json'
      security [bearer_auth: []]

      include_context "olive branch casing parameter"
      include_context "olive branch camelcasing"

      it_behaves_like "coach spec unauthenticated openapi"

      context "when authenticated" do
        include_context "coach authenticated openapi"

        response '200', 'Returns all attributes' do
          schema type: :array,
                 items: {
                   type: :object,
                   properties: {
                     id: { type: :string, format: :uuid },
                     description: { type: :string, nullable: true },
                     name: { type: :string },
                     set: { type: :array, items: { type: :string } },
                     default: { type: :array, items: { type: :string } }
                   }
                 }

          let!(:attribute) { create(:attributes_attribute) }

          before do
            expect(Attributes::AttributesQuery)
              .to receive(:all)
              .and_call_original
          end

          run_test!
        end
      end
    end
  end

  path '/coaches/seekers/{person_id}/attributes' do
    let(:attribute) { create(:attributes_attribute) }

    post "Add an attribute" do
      tags 'Coaches'
      consumes 'application/json'
      parameter name: :person_id, in: :path, type: :string
      parameter name: :attribute_params, in: :body, schema: {
        type: :object,
        properties: {
          attributeId: {
            type: :string,
            format: :uuid
          },
          values: {
            type: :array,
            items: {
              type: :string
            }
          }
        },
        required: %w[attributesId name value]
      }
      security [bearer_auth: []]

      include_context "olive branch casing parameter"
      include_context "olive branch camelcasing"

      it_behaves_like "coach spec unauthenticated openapi"

      let(:person_context) { create(:coaches__person_context) }
      let(:person_id) { person_context.id }
      let(:attribute_params) do
        {
          attributeId: attribute_id,
          values:
        }
      end
      let(:attribute_id) { attribute.id }
      let(:values) { ["A value"] }

      context "when authenticated" do
        include_context "coach authenticated openapi"

        response '201', 'Adds an attribute' do
          before do
            expect_any_instance_of(Coaches::CoachesEventEmitter)
              .to receive(:add_attribute)
              .with(
                person_attribute_id: be_a(String),
                person_id:,
                attribute_id:,
                attribute_name: attribute.name,
                attribute_values: values,
                trace_id: be_a(String)
              )
              .and_call_original
          end

          run_test!
        end
      end
    end
  end

  path '/coaches/seekers/{person_id}/attributes/{id}' do
    let(:attribute) { create(:attributes_attribute) }

    put "update an attribute" do
      tags 'Coaches'
      consumes 'application/json'
      parameter name: :person_id, in: :path, type: :string
      parameter name: :id, in: :path, type: :string
      parameter name: :attribute_params, in: :body, schema: {
        type: :object,
        properties: {
          attributeId: {
            type: :string,
            format: :uuid
          },
          value: {
            type: :array,
            items: {
              type: :string
            }
          }
        },
        required: %w[attributesId name value]
      }
      security [bearer_auth: []]

      include_context "olive branch casing parameter"
      include_context "olive branch camelcasing"

      it_behaves_like "coach spec unauthenticated openapi"

      let(:person_context) { create(:coaches__person_context) }
      let(:person_id) { person_context.id }
      let(:id) { seeker_attribute.id }
      let(:seeker_attribute) { create(:coaches__person_attribute) }
      let(:attribute_params) do
        {
          attributeId: attribute_id,
          values:
        }
      end
      let(:attribute_id) { attribute.id }
      let(:values) { ["A value"] }

      context "when authenticated" do
        include_context "coach authenticated openapi"

        response '202', 'Adds an attribute' do
          before do
            expect_any_instance_of(Coaches::CoachesEventEmitter)
              .to receive(:add_attribute)
              .with(
                person_attribute_id: id,
                person_id:,
                attribute_id:,
                attribute_name: attribute.name,
                attribute_values: values,
                trace_id: be_a(String)
              )
              .and_call_original
          end

          run_test!
        end
      end
    end

    delete "remove an attribute" do
      tags 'Coaches'
      parameter name: :person_id, in: :path, type: :string
      parameter name: :id, in: :path, type: :string
      security [bearer_auth: []]

      include_context "olive branch casing parameter"
      include_context "olive branch camelcasing"

      it_behaves_like "coach spec unauthenticated openapi"

      let(:person_context) { create(:coaches__person_context) }
      let(:person_id) { person_context.id }
      let(:id) { seeker_attribute.id }
      let(:seeker_attribute) { create(:coaches__person_attribute) }

      context "when authenticated" do
        include_context "coach authenticated openapi"

        response '202', 'Removes an attribute' do
          before do
            expect_any_instance_of(Coaches::CoachesEventEmitter)
              .to receive(:remove_attribute)
              .with(
                person_attribute_id: id,
                person_id:,
                trace_id: be_a(String)
              )
              .and_call_original
          end

          run_test!
        end
      end
    end
  end
end

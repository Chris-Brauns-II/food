require 'rails_helper'
require 'swagger_helper'

RSpec.describe "Attributes", type: :request do
  path '/admin/attributes' do
    get "get all attributes" do
      tags 'Admin'
      produces 'application/json'
      security [bearer_auth: []]

      include_context "olive branch casing parameter"
      include_context "olive branch camelcasing"

      it_behaves_like "admin spec unauthenticated openapi"

      context "when authenticated" do
        include_context "admin authenticated openapi"

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

    post "create an attribute" do
      tags 'Admin'
      produces 'application/json'
      consumes 'application/json'
      security [bearer_auth: []]

      include_context "olive branch casing parameter"
      include_context "olive branch camelcasing"

      it_behaves_like "admin spec unauthenticated openapi"

      let(:attribute) do
        {
          name: "name",
          description: "description",
          set: %w[A B],
          default: ["B"]
        }
      end

      context "when authenticated" do
        include_context "admin authenticated openapi"

        parameter name: :attribute, in: :body, schema: {
          type: :object,
          properties: {
            name: { type: :string },
            description: { type: :string },
            set: { type: :array, items: { type: :string } },
            default: { type: :array, items: { type: :string } }
          },
          required: %w[name set default]
        }

        response '201', 'Creates an attribute' do
          before do
            expect_any_instance_of(Attributes::AttributesReactor)
              .to receive(:create)
              .with(attribute_id: anything, name: "name", description: "description", set: %w[A B], default: ["B"])
              .and_call_original
          end

          run_test!
        end
      end
    end
  end

  path '/admin/attributes/{id}' do
    put "update an attribute" do
      tags 'Admin'
      produces 'application/json'
      consumes 'application/json'
      parameter name: :id, in: :path, type: :string
      parameter name: :attribute, in: :body, schema: {
        type: :object,
        properties: {
          name: { type: :string },
          description: { type: :string },
          set: { type: :array, items: { type: :string } },
          default: { type: :array, items: { type: :string } }
        }
      }
      security [bearer_auth: []]

      include_context "olive branch casing parameter"
      include_context "olive branch camelcasing"

      let(:id) { create(:attributes_attribute).id }
      let(:attribute) do
        {
          name: "new name",
          description: "new description",
          set: %w[C D],
          default: ["D"]
        }
      end

      it_behaves_like "admin spec unauthenticated openapi"

      context "when authenticated" do
        include_context "admin authenticated openapi"

        response '204', 'Updates an attribute' do
          before do
            expect_any_instance_of(Attributes::AttributesReactor)
              .to receive(:update)
              .with(attribute_id: id, name: "new name", description: "new description", set: %w[C D], default: ["D"])
              .and_call_original
          end

          run_test!
        end
      end
    end

    delete "delete an attribute" do
      tags 'Admin'
      produces 'application/json'
      parameter name: :id, in: :path, type: :string
      security [bearer_auth: []]

      include_context "olive branch casing parameter"
      include_context "olive branch camelcasing"

      let(:id) { create(:attributes_attribute).id }

      it_behaves_like "admin spec unauthenticated openapi"

      context "when authenticated" do
        include_context "admin authenticated openapi"

        response '204', 'Deletes an attribute' do
          before do
            expect_any_instance_of(Attributes::AttributesReactor)
              .to receive(:destroy)
              .with(attribute_id: id)
              .and_call_original
          end

          run_test!
        end
      end
    end
  end
end

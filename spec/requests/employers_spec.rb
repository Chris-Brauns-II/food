require 'rails_helper'
require 'swagger_helper'

RSpec.describe "Employers", type: :request do
  path '/employers' do
    post "Create an employer" do
      tags 'Admin'
      consumes 'application/json'
      security [bearer_auth: []]
      parameter name: :employer_params, in: :body, schema: {
        type: :object,
        properties: {
          name: { type: :string },
          location: { type: :string },
          bio: { type: :string },
          logoUrl: { type: :string }
        },
        required: %w[name location bio logoUrl]
      }

      let(:employer_params) do
        {
          name: "name",
          location: "location",
          bio: "bio",
          logoUrl: "logoUrl"
        }
      end

      include_context "olive branch casing parameter"
      include_context "olive branch camelcasing"

      it_behaves_like "admin spec unauthenticated openapi"

      context "admin authenticated" do
        include_context "admin authenticated openapi"

        response '201', 'Request employer create' do
          before do
            expect_any_instance_of(MessageService)
              .to receive(:create!)
              .with(
                trace_id: be_a(String),
                employer_id: be_a(String),
                schema: Commands::CreateEmployer::V1,
                data: {
                  name: employer_params[:name],
                  location: employer_params[:location],
                  bio: employer_params[:bio],
                  logo_url: employer_params[:logoUrl]
                }
              )
              .and_call_original
          end

          run_test!
        end
      end
    end

    get "Get all employers" do
      tags 'Admin'
      produces 'application/json'
      security [bearer_auth: []]

      include_context "olive branch casing parameter"
      include_context "olive branch camelcasing"

      it_behaves_like "admin spec unauthenticated openapi"

      context "admin authenticated" do
        include_context "admin authenticated openapi"

        response '200', 'Retrieve all employers' do
          schema type: :array,
                 items: {
                   '$ref' => '#/components/schemas/employer'
                 }

          before do
            create(:employer)
            create(:employer)
            create(:employer)
          end

          run_test!
        end
      end
    end
  end

  path '/employers/{id}' do
    put "Update an employer" do
      tags 'Admin'
      consumes 'application/json'
      security [bearer_auth: []]
      parameter name: :id, in: :path, type: :string
      parameter name: :employer_params, in: :body, schema: {
        type: :object,
        properties: {
          name: { type: :string },
          location: { type: :string },
          bio: { type: :string },
          logoUrl: { type: :string }
        },
        required: %w[name location bio logoUrl]
      }

      let(:employer_params) do
        {
          name: "name",
          location: "location",
          bio: "bio",
          logoUrl: "logoUrl"
        }
      end
      let(:id) { SecureRandom.uuid }

      include_context "olive branch casing parameter"
      include_context "olive branch camelcasing"

      it_behaves_like "admin spec unauthenticated openapi"

      context "admin authenticated" do
        include_context "admin authenticated openapi"

        response '202', 'Request employer updated' do
          before do
            expect_any_instance_of(MessageService)
              .to receive(:create!)
              .with(
                trace_id: be_a(String),
                employer_id: id,
                schema: Commands::UpdateEmployer::V1,
                data: {
                  name: employer_params[:name],
                  location: employer_params[:location],
                  bio: employer_params[:bio],
                  logo_url: employer_params[:logoUrl]
                }
              )
              .and_call_original
          end

          run_test!
        end
      end
    end

    get "Get one employers" do
      tags 'Admin'
      produces 'application/json'
      security [bearer_auth: []]
      parameter name: :id, in: :path, type: :string

      let(:employer) { create(:employer) }
      let(:id) { employer.id }

      include_context "olive branch casing parameter"
      include_context "olive branch camelcasing"

      it_behaves_like "admin spec unauthenticated openapi"

      context "admin authenticated" do
        include_context "admin authenticated openapi"

        response '200', 'Retrieve one employers' do
          schema '$ref' => '#/components/schemas/employer'

          run_test!
        end
      end
    end
  end
end

require 'rails_helper'

RSpec.describe "Users", type: :request do
  describe "PUT /users/:id" do
    subject { put user_path(user_to_edit), params:, headers: }

    let(:user_to_edit) { create(:user) }
    let(:params) do
      {
        about: "New About",
        first_name: "New First Name",
        last_name: "Name Last Name",
        phone_number: "1234567890",
        zip_code: "12345"
      }
    end

    context "unauthenticated" do
      it "returns 401" do
        subject

        expect(response).to have_http_status(:unauthorized)
      end
    end

    context "authenticated" do
      include_context "authenticated"

      context "when the user is not the user to edit" do
        context "when the user is not a coach" do
          it "returns 401" do
            subject

            expect(response).to have_http_status(:unauthorized)
          end
        end

        context "when the user is a coach" do
          include_context "coach authenticated"

          it "return 200" do
            subject

            expect(response).to have_http_status(:ok)
          end

          it "calls UserService.update" do
            expect_any_instance_of(People::BasicInfoService).to receive(:update).with(
              about: "New About",
              first_name: "New First Name",
              last_name: "Name Last Name",
              phone_number: "1234567890",
              zip_code: "12345",
              email: user.email
            ).and_call_original

            subject
          end
        end
      end

      context "when the user is the user to edit" do
        let(:user_to_edit) { user }

        it "returns 200" do
          subject

          expect(response).to have_http_status(:ok)
        end

        it "calls UserService.update" do
          expect_any_instance_of(People::BasicInfoService).to receive(:update).with(
            about: "New About",
            first_name: "New First Name",
            last_name: "Name Last Name",
            phone_number: "1234567890",
            zip_code: "12345",
            email: user.email
          ).and_call_original

          subject
        end
      end
    end
  end
end

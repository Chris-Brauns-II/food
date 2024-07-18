require 'rails_helper'

RSpec.describe "MasterSkills", type: :request do
  describe "GET /index" do
    subject { get master_skills_path, headers: }

    it "returns a 200" do
      subject

      expect(response).to have_http_status(:ok)
    end
  end
end

require 'rails_helper'

RSpec.describe "MasterCertifications", type: :request do
  describe "GET /index" do
    subject { get master_certifications_path, headers: }

    it_behaves_like "admin secured endpoint"
  end
end

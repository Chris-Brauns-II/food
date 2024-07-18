require 'rails_helper'

RSpec.describe "PassReasons", type: :request do
  describe "GET /index" do
    subject { get pass_reasons_path, headers: }

    it_behaves_like "employer secured endpoint"
  end
end

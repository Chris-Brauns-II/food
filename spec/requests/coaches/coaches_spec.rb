require 'rails_helper'

RSpec.describe "Coaches", type: :request do
  describe "GET /index" do
    subject { get coaches_path, headers: }

    it_behaves_like "coach secured endpoint"

    context "authenticated" do
      include_context "coach authenticated"

      it "calls CoachService.all" do
        expect(Coaches::CoachesQuery).to receive(:all_coaches)

        subject
      end
    end
  end
end

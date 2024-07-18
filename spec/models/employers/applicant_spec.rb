require 'rails_helper'

RSpec.describe Employers::Applicant do
  describe ".active" do
    subject { described_class.active }

    let!(:pass) { create(:employers_applicant, status: described_class::StatusTypes::PASS) }
    let!(:hire) { create(:employers_applicant, status: described_class::StatusTypes::HIRE) }
    let!(:interviewing) { create(:employers_applicant, status: described_class::StatusTypes::INTERVIEWING) }
    let!(:intro_made) { create(:employers_applicant, status: described_class::StatusTypes::INTRO_MADE) }
    let!(:pending_intro) { create(:employers_applicant, status: described_class::StatusTypes::PENDING_INTRO) }
    let!(:new_app) { create(:employers_applicant, status: described_class::StatusTypes::NEW) }

    it "returns applicants non-terminal applicants" do
      expect(subject).to match_array([new_app, pending_intro, intro_made, interviewing])
    end
  end
end

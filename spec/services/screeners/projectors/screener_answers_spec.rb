require 'rails_helper'

RSpec.describe Screeners::Projectors::ScreenerAnswers do
  describe ".project" do
    subject { described_class.new.project(messages) }

    let(:stream) { Screeners::Streams::Answers.new(screener_answers_id:) }
    let(:screener_answers_id) { SecureRandom.uuid }

    let(:now) { Time.zone.now }

    let(:answers_created) do
      build(
        :message,
        stream:,
        schema: Screeners::Events::AnswersCreated::V2,
        data: {
          title: "Great Screener",
          person_id: SecureRandom.uuid,
          question_responses: [
            Screeners::QuestionResponse.new(
              question: "Are you cool?",
              response: "Yes"
            )
          ]
        }
      )
    end
    let(:answers_updated) do
      build(
        :message,
        stream:,
        schema: Screeners::Events::AnswersUpdated::V1,
        data: {
          title: "Better Screener",
          question_responses: [
            Screeners::QuestionResponse.new(
              question: "Are you lame",
              response: "No"
            )
          ]
        }
      )
    end

    let(:messages) { [answers_created, answers_updated] }

    it "projects the answers" do
      expect(subject.title).to eq(answers_updated.data.title)
      expect(subject.person_id).to eq(answers_created.data.person_id)
      expect(subject.question_responses).to eq(answers_updated.data.question_responses)
    end
  end
end

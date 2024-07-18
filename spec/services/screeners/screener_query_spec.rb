require 'rails_helper'

RSpec.describe Screeners::ScreenerQuery do
  describe ".all_questions" do
    subject { described_class.all_questions }

    let!(:questions1) { create(:screeners__questions) }
    let!(:questions2) { create(:screeners__questions) }

    let(:serialized_question1) do
      {
        id: questions1.id,
        title: questions1.title,
        questions: questions1.questions
      }
    end
    let(:serialized_question2) do
      {
        id: questions2.id,
        title: questions2.title,
        questions: questions2.questions
      }
    end

    it "returns the questions" do
      expect(subject).to contain_exactly(serialized_question1, serialized_question2)
    end
  end

  describe ".find_questions" do
    subject { described_class.find_questions(questions.id) }

    let(:questions) { create(:screeners__questions) }

    it "returns the questions" do
      expect(subject).to eq({
                              id: questions.id,
                              title: questions.title,
                              questions: questions.questions
                            })
    end
  end

  describe ".find_answers" do
    subject { described_class.find_answers(answers.id) }

    let(:answers) { create(:screeners__answers) }

    it "returns the answers" do
      expect(subject).to eq({
                              id: answers.id,
                              title: answers.title,
                              person_id: answers.person_id,
                              screener_questions_id: answers.screeners_questions_id,
                              question_responses: answers.question_responses
                            })
    end
  end
end

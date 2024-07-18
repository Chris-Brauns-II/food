require 'rails_helper'

RSpec.describe Screeners::ScreenerReactor do
  it_behaves_like "a replayable message consumer"

  before do
    messages.each do |message|
      Event.from_message!(message)
    end
  end

  let(:consumer) { described_class.new(message_service:) }
  let(:message_service) { MessageService.new }
  let(:trace_id) { SecureRandom.uuid }
  let(:messages) { [] }
  let(:questions_stream) { Screeners::Streams::Questions.new(screener_questions_id:) }
  let(:answers_stream) { Screeners::Streams::Answers.new(screener_answers_id:) }
  let(:screener_questions_id) { SecureRandom.uuid }
  let(:screener_answers_id) { SecureRandom.uuid }

  describe "#handle_message" do
    subject { consumer.handle_message(message) }

    context "when the message is create screener answer" do
      let(:message) do
        build(
          :message,
          schema: Screeners::Commands::CreateAnswers::V2,
          data: {
            screener_questions_id:
          }
        )
      end

      context "when the associated questions exists" do
        let(:messages) do
          [
            build(
              :message,
              stream: questions_stream,
              schema: Screeners::Events::QuestionsCreated::V1
            )
          ]
        end

        it "emits an answers created event" do
          expect(message_service)
            .to receive(:create_once_for_stream!)
            .with(
              trace_id: message.trace_id,
              stream: message.stream,
              schema: Screeners::Events::AnswersCreated::V2,
              data: {
                title: message.data.title,
                person_id: message.data.person_id,
                screener_questions_id: message.data.screener_questions_id,
                question_responses: message.data.question_responses
              },
              metadata: message.metadata
            )
            .and_call_original

          subject
        end
      end

      context "when the associated questions doesn't exists" do
        let(:message_service) { double }

        it "does nothing" do
          subject
        end
      end
    end

    context "when the message is create screener questions" do
      let(:message) do
        build(
          :message,
          schema: Screeners::Commands::CreateQuestions::V1
        )
      end

      it "emits an answers created event" do
        expect(message_service)
          .to receive(:create_once_for_stream!)
          .with(
            trace_id: message.trace_id,
            stream: message.stream,
            schema: Screeners::Events::QuestionsCreated::V1,
            data: {
              title: message.data.title,
              questions: message.data.questions
            },
            metadata: message.metadata
          )
          .and_call_original

        subject
      end
    end

    context "when the message is update screener answers" do
      let(:message) do
        build(
          :message,
          schema: Screeners::Commands::UpdateAnswers::V1,
          stream: answers_stream
        )
      end

      context "when there are already answers" do
        let(:messages) do
          [
            build(
              :message,
              schema: Screeners::Events::AnswersCreated::V2,
              stream: answers_stream
            )
          ]
        end

        it "emits an answers created event" do
          expect(message_service)
            .to receive(:create_once_for_trace!)
            .with(
              trace_id: message.trace_id,
              stream: message.stream,
              schema: Screeners::Events::AnswersUpdated::V1,
              data: {
                title: message.data.title,
                question_responses: message.data.question_responses
              },
              metadata: message.metadata
            )
            .and_call_original

          subject
        end
      end

      context "when there are not answer" do
        let(:message_service) { double }

        it "does nothing" do
          subject
        end
      end
    end

    context "when the message is update screener questions" do
      let(:message) do
        build(
          :message,
          schema: Screeners::Commands::UpdateQuestions::V1,
          stream: questions_stream
        )
      end

      context "when there are already answers" do
        let(:messages) do
          [
            build(
              :message,
              schema: Screeners::Events::QuestionsCreated::V1,
              stream: questions_stream
            )
          ]
        end

        it "emits an answers created event" do
          expect(message_service)
            .to receive(:create_once_for_trace!)
            .with(
              trace_id: message.trace_id,
              stream: message.stream,
              schema: Screeners::Events::QuestionsUpdated::V1,
              data: {
                title: message.data.title,
                questions: message.data.questions
              },
              metadata: message.metadata
            )
            .and_call_original

          subject
        end
      end

      context "when there are not answer" do
        let(:message_service) { double }

        it "does nothing" do
          subject
        end
      end
    end
  end
end

require 'rails_helper'

RSpec.describe People::PersonDedupingReactor do
  it_behaves_like "a replayable message consumer"

  let(:consumer) { described_class.new(message_service:) }
  let(:message_service) { MessageService.new }
  let(:person_id) { SecureRandom.uuid }
  let(:trace_id) { SecureRandom.uuid }
  let(:user_id) { SecureRandom.uuid }

  describe "#handle_message" do
    subject do
      consumer.handle_message(message)
      consumer.handle_message(message)
    end

    context "when the message is add person" do
      let(:message) do
        build(
          :message,
          schema: Commands::AddPerson::V2,
          stream_id: person_id,
          trace_id:,
          data: {
            user_id:,
            first_name: "Jim",
            last_name: "Bo",
            email:,
            phone_number:,
            source_kind:,
            source_identifier:,
            date_of_birth:
          }
        )
      end

      before do
        messages.each do |message|
          Event.from_message!(message)
        end
      end

      let(:user_id) { nil }
      let(:phone_number) { "333-333-3333" }
      let(:date_of_birth) { Time.zone.parse("10/09/1990") }
      let(:email) { "a@b.c" }
      let(:messages) { [] }
      let(:source_identifier) { "an identifier" }
      let(:source_kind) { People::SourceKind::COACH }

      let(:person_added) do
        build(
          :message,
          stream_id: person_id,
          schema: Events::PersonAdded::V1,
          data: {
            first_name: "Jim",
            last_name: "Bo",
            email:,
            phone_number:,
            date_of_birth: Time.zone.parse("1/1/2000")
          }
        )
      end
      let(:person_associated_email) do
        build(
          :message,
          stream_id: email,
          schema: Events::PersonAssociatedToEmail::V1,
          data: {
            person_id:
          }
        )
      end
      let(:person_associated_phone_number) do
        build(
          :message,
          stream_id: phone_number,
          schema: Events::PersonAssociatedToPhoneNumber::V1,
          data: {
            person_id:
          }
        )
      end

      context "when person added has already executed" do
        let(:messages) { [person_added] }
        let(:message_service) { double }

        it "does nothing" do
          subject
        end
      end

      context "when user id is present" do
        let(:user_id) { SecureRandom.uuid }

        context "when there is a matching email" do
          let(:messages) { [person_associated_email] }

          it "emits a person associated to user event" do
            expect(message_service)
              .to receive(:create_once_for_stream!)
              .with(
                schema: Events::PersonAssociatedToUser::V1,
                trace_id:,
                person_id:,
                data: {
                  user_id:
                }
              )
              .twice
              .and_call_original

            expect(message_service)
              .to receive(:save!)
              .once
              .and_call_original

            subject
          end
        end

        context "when there is a matching phone" do
          let(:messages) { [person_associated_phone_number] }

          it "associates the user" do
            expect(message_service)
              .to receive(:create_once_for_stream!)
              .with(
                schema: Events::PersonAssociatedToUser::V1,
                trace_id:,
                person_id:,
                data: {
                  user_id:
                }
              )
              .twice
              .and_call_original

            expect(message_service)
              .to receive(:save!)
              .once
              .and_call_original

            subject
          end
        end

        context "when there is not a match" do
          it "emits a person added, sourced and associated with user events" do
            expect(message_service)
              .to receive(:create_once_for_trace!)
              .with(
                schema: Events::PersonAdded::V1,
                trace_id:,
                person_id:,
                data: {
                  first_name: "Jim",
                  last_name: "Bo",
                  email: message.data.email,
                  phone_number: message.data.phone_number,
                  date_of_birth: message.data.date_of_birth
                }
              )
              .and_call_original

            expect(message_service)
              .to receive(:create_once_for_stream!)
              .with(
                schema: Events::PersonAssociatedToUser::V1,
                trace_id:,
                person_id:,
                data: {
                  user_id:
                }
              )
              .and_call_original

            expect(message_service)
              .to receive(:create_once_for_stream!)
              .with(
                schema: Events::PersonSourced::V1,
                trace_id:,
                person_id:,
                data: {
                  source_kind:,
                  source_identifier:
                }
              )
              .and_call_original

            subject
          end
        end
      end

      context "when user id is absent" do
        let(:user_id) { nil }

        context "when there is a matching email" do
          let(:messages) { [person_associated_email] }
          let(:message_service) { double }

          it "does nothing" do
            subject
          end
        end

        context "when there is a matching phone" do
          let(:messages) { [person_associated_phone_number] }
          let(:message_service) { double }

          it "does nothing" do
            subject
          end
        end

        context "when there is not a match" do
          it "emits a person added and sourced events" do
            expect(message_service)
              .to receive(:create_once_for_trace!)
              .with(
                schema: Events::PersonAdded::V1,
                trace_id: message.trace_id,
                person_id: message.stream.id,
                data: {
                  first_name: message.data.first_name,
                  last_name: message.data.last_name,
                  email: message.data.email,
                  phone_number: message.data.phone_number,
                  date_of_birth: message.data.date_of_birth
                }
              )
              .and_call_original

            expect(message_service)
              .to receive(:create_once_for_stream!)
              .with(
                schema: Events::PersonSourced::V1,
                trace_id:,
                person_id:,
                data: {
                  source_kind:,
                  source_identifier:
                }
              )
              .and_call_original

            subject

            subject
          end
        end
      end
    end

    context "when the message is person added" do
      let(:message) do
        build(
          :message,
          schema: Events::PersonAdded::V1,
          stream_id: person_id,
          trace_id:,
          data: {
            first_name: "Jim",
            last_name: "Bo",
            email:,
            phone_number:,
            date_of_birth: "10/09/1990"
          }
        )
      end

      context "when email is present" do
        let(:email) { "a@b.c" }
        let(:phone_number) { nil }

        it "emits a person associated to email event" do
          expect(message_service)
            .to receive(:create_once_for_trace!)
            .with(
              schema: Events::PersonAssociatedToEmail::V1,
              trace_id: message.trace_id,
              email: message.data.email,
              data: {
                person_id: message.stream.id
              }
            )
            .twice
            .and_call_original

          expect(message_service)
            .to receive(:save!)
            .once
            .and_call_original

          subject
        end
      end

      context "when phone is present" do
        let(:email) { nil }
        let(:phone_number) { "333-333-3333" }

        it "emits a person associated to phone number event" do
          expect(message_service)
            .to receive(:create_once_for_trace!)
            .with(
              schema: Events::PersonAssociatedToPhoneNumber::V1,
              trace_id: message.trace_id,
              phone_number: message.data.phone_number,
              data: {
                person_id: message.stream.id
              }
            )
            .twice
            .and_call_original

          expect(message_service)
            .to receive(:save!)
            .once
            .and_call_original

          subject
        end
      end

      context "when both is present" do
        let(:email) { "a@b.c" }
        let(:phone_number) { "333-333-3333" }

        it "emits both events event" do
          expect(message_service)
            .to receive(:create_once_for_trace!)
            .with(
              schema: Events::PersonAssociatedToPhoneNumber::V1,
              trace_id: message.trace_id,
              phone_number: message.data.phone_number,
              data: {
                person_id: message.stream.id
              }
            )
            .twice
            .and_call_original

          expect(message_service)
            .to receive(:create_once_for_trace!)
            .with(
              schema: Events::PersonAssociatedToEmail::V1,
              trace_id: message.trace_id,
              email: message.data.email,
              data: {
                person_id: message.stream.id
              }
            )
            .twice
            .and_call_original

          expect(message_service)
            .to receive(:save!)
            .twice
            .and_call_original

          subject
        end
      end
    end
  end
end

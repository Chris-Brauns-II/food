require 'rails_helper'

RSpec.describe MessageReactor do
  describe "#flush" do
    subject { described_class.new(message_service:).flush }
    let(:message_service) { MessageService.new }

    it "calls flush on the message service" do
      expect(message_service)
        .to receive(:flush)

      expect(subject).to eq(nil)
    end
  end
end

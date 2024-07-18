require 'rails_helper'

RSpec.describe Jobs::JobsReactor do
  it_behaves_like "a replayable message consumer"

  let(:message_service) { MessageService.new }
  let(:consumer) { described_class.new(message_service:) }

  describe "#create_job_attribute" do
    subject { consumer.create_job_attribute(job_id:, attribute_id:, acceptible_set:) }

    let(:job_id) { create(:job).id }
    let(:attribute) { create(:attributes_attribute, set: %w[A B]) }
    let(:attribute_id) { attribute.id }
    let(:acceptible_set) { %w[A] }

    it "creates an event" do
      expect(message_service).to receive(:create!).with(
        schema: Events::JobAttributeCreated::V1,
        job_id:,
        data: {
          id: kind_of(String),
          attribute_name: attribute.name,
          attribute_id:,
          acceptible_set:
        }
      ).and_call_original

      subject
    end
  end

  describe "#update_job_attribute" do
    subject { consumer.update_job_attribute(job_id: job_attribute.job_id, job_attribute_id:, acceptible_set:) }

    let(:job_attribute) { create(:job_attribute, acceptible_set: %w[A B]) }
    let(:job_attribute_id) { job_attribute.id }
    let(:acceptible_set) { %w[A] }

    it "creates an event" do
      expect(message_service).to receive(:create!).with(
        schema: Events::JobAttributeUpdated::V1,
        job_id: job_attribute.job_id,
        data: {
          id: job_attribute.id,
          acceptible_set:
        }
      ).and_call_original

      subject
    end
  end

  describe "#destroy_job_attribute" do
    subject { consumer.destroy_job_attribute(job_id: job_attribute.job_id, job_attribute_id:) }

    let(:job_attribute) { create(:job_attribute) }
    let(:job_attribute_id) { job_attribute.id }

    it "creates an event" do
      expect(message_service).to receive(:create!).with(
        schema: Events::JobAttributeDestroyed::V1,
        job_id: job_attribute.job_id,
        data: {
          id: job_attribute.id
        }
      ).and_call_original

      subject
    end
  end

  describe "#handle_message" do
    subject do
      consumer.handle_message(message)
      consumer.handle_message(message)
    end

    before do
      messages.each do |m|
        Event.from_message!(m)
      end
    end

    let(:messages) { [] }
    let(:stream) { Streams::Job.new(job_id:) }
    let(:id) { SecureRandom.uuid }
    let(:job_id) { SecureRandom.uuid }
    let(:employer_id) { SecureRandom.uuid }
    let(:master_certification_id) { SecureRandom.uuid }

    let(:job_created) do
      build(
        :message,
        stream:,
        schema: Events::JobCreated::V3,
        data: {
          category: Job::Categories::MARKETPLACE,
          employment_title: "A title",
          employer_name: "An employer",
          employer_id: SecureRandom.uuid,
          benefits_description: "Bad benifits",
          responsibilities_description: nil,
          location: "Columbus Ohio",
          employment_type: Job::EmploymentTypes::FULLTIME,
          hide_job: false
        }
      )
    end

    let(:employer_created) do
      build(
        :message,
        schema: Events::EmployerCreated::V1,
        stream_id: employer_id,
        data: {
          name: "name",
          location: "location",
          bio: "bio",
          logo_url: "logo_url"
        }
      )
    end

    let(:desired_certification_created) do
      build(
        :message,
        stream:,
        schema: Events::DesiredCertificationCreated::V1,
        data: {
          id:,
          job_id:,
          master_certification_id:
        }
      )
    end

    context "when message is add desired certification" do
      let(:message) do
        build(
          :message,
          stream:,
          schema: Commands::AddDesiredCertification::V1,
          data: {
            id:,
            master_certification_id:
          }
        )
      end

      context "when the job has not been created" do
        let(:messages) { [] }
        let(:message_service) { double }

        it "does nothing" do
          subject
        end
      end

      context "when the certification has already been added" do
        let(:messages) { [job_created, desired_certification_created] }
        let(:message_service) { double }

        it "does nothing" do
          subject
        end
      end

      context "when the certification has not already been added" do
        let(:messages) { [job_created] }

        it "emits a desired certification created event" do
          expect(message_service)
            .to receive(:create_once_for_trace!)
            .with(
              trace_id: message.trace_id,
              stream: message.stream,
              schema: Events::DesiredCertificationCreated::V1,
              data: {
                id: message.data.id,
                job_id: message.stream.id,
                master_certification_id: message.data.master_certification_id
              }
            )
            .twice
            .and_call_original

          subject
        end
      end
    end

    context "when message is remove desired certification" do
      let(:message) do
        build(
          :message,
          stream:,
          schema: Commands::RemoveDesiredCertification::V1,
          data: {
            id:
          }
        )
      end

      context "when the job has not been created" do
        let(:messages) { [] }
        let(:message_service) { double }

        it "does nothing" do
          subject
        end
      end

      context "when the certification has not already been added" do
        let(:messages) { [job_created] }
        let(:message_service) { double }

        it "does nothing" do
          subject
        end
      end

      context "when the certification has already been added" do
        let(:messages) { [job_created, desired_certification_created] }

        it "emits a desired certification deleted event" do
          expect(message_service)
            .to receive(:create_once_for_trace!)
            .with(
              trace_id: message.trace_id,
              stream: message.stream,
              schema: Events::DesiredCertificationDestroyed::V1,
              data: {
                id: message.data.id
              }
            )
            .twice
            .and_call_original

          subject
        end
      end
    end

    context "when message is create employer" do
      let(:message) do
        build(
          :message,
          schema: Commands::CreateEmployer::V1,
          stream_id: employer_id,
          data: {
            name: "name",
            location: "location",
            bio: "bio",
            logo_url: "logo_url"
          }
        )
      end

      it "emits a employer created event" do
        expect(message_service)
          .to receive(:create_once_for_stream!)
          .with(
            trace_id: message.trace_id,
            stream: message.stream,
            schema: Events::EmployerCreated::V1,
            data: {
              name: message.data.name,
              location: message.data.location,
              bio: message.data.bio,
              logo_url: message.data.logo_url
            }
          )
          .twice
          .and_call_original

        subject
      end
    end

    context "when message is update employer" do
      let(:message) do
        build(
          :message,
          schema: Commands::UpdateEmployer::V1,
          stream_id: employer_id,
          data: {
            name: "name",
            location: "location",
            bio: "bio",
            logo_url: "logo_url"
          }
        )
      end

      context "when the employer has not been created" do
        let(:messages) { [] }
        let(:message_service) { double }

        it "does nothing" do
          subject
        end
      end

      context "when the employer has been created" do
        let(:messages) { [employer_created] }

        it "emits a employer created event" do
          expect(message_service)
            .to receive(:create_once_for_trace!)
            .with(
              trace_id: message.trace_id,
              stream: message.stream,
              schema: Events::EmployerUpdated::V1,
              data: {
                name: message.data.name,
                location: message.data.location,
                bio: message.data.bio,
                logo_url: message.data.logo_url
              }
            )
            .twice
            .and_call_original

          subject
        end
      end
    end
  end
end

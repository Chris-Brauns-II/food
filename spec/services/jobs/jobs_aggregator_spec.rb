require 'rails_helper'

RSpec.describe Jobs::JobsAggregator do
  it_behaves_like "a replayable message consumer"

  let(:consumer) { described_class.new }
  let(:id) { SecureRandom.uuid }

  describe "#handle_message" do
    subject { consumer.handle_message(message) }

    context "CareerPathCreated" do
      let(:message) do
        build(
          :message,
          schema: Events::CareerPathCreated::V1,
          stream_id: job.id,
          data: {
            id:,
            job_id: job.id,
            title: "title",
            order: 0,
            lower_limit: "1",
            upper_limit: "2"
          }
        )
      end
      let(:id) { SecureRandom.uuid }
      let(:job) { create(:job) }

      it "creates a career path" do
        expect { subject }.to change { CareerPath.count }.by(1)
      end
    end

    context "CareerPathUpdated" do
      let(:message) do
        build(
          :message,
          schema: Events::CareerPathUpdated::V1,
          stream_id: career_path.job_id,
          data: {
            id: career_path.id,
            order: 1
          }
        )
      end
      let(:career_path) { create(:career_path) }

      it "updates a career path" do
        expect { subject }.to change { career_path.reload.order }.from(0).to(1)
      end
    end

    context "CareerPathDestroyed" do
      let(:message) do
        build(
          :message,
          schema: Events::CareerPathDestroyed::V1,
          stream_id: career_path.job_id,
          data: {
            id: career_path.id
          }
        )
      end
      let!(:career_path) { create(:career_path) }

      it "destroys a career path" do
        expect { subject }.to change { CareerPath.count }.by(-1)
      end
    end

    context "DesiredCertificationCreated" do
      let(:message) do
        build(
          :message,
          schema: Events::DesiredCertificationCreated::V1,
          stream_id: job.id,
          data: {
            id:,
            job_id: job.id,
            master_certification_id: master_certification.id
          }
        )
      end
      let(:id) { SecureRandom.uuid }
      let(:job) { create(:job) }
      let(:master_certification) { create(:master_certification) }

      it "creates a desired certification" do
        expect { subject }.to change { DesiredCertification.count }.by(1)

        desired_certification = DesiredCertification.last

        expect(desired_certification.id).to eq(id)
        expect(desired_certification.job_id).to eq(job.id)
        expect(desired_certification.master_certification_id).to eq(master_certification.id)
      end
    end

    context "DesiredCertificationDestroyed" do
      let(:message) do
        build(
          :message,
          schema: Events::DesiredCertificationDestroyed::V1,
          stream_id: desired_certification.job_id,
          data: {
            id: desired_certification.id
          }
        )
      end
      let!(:desired_certification) { create(:desired_certification) }

      it "destroys a desired certification" do
        expect { subject }.to change { DesiredCertification.count }.by(-1)
      end
    end

    context "DesiredSkillCreated" do
      let(:message) do
        build(
          :message,
          schema: Events::DesiredSkillCreated::V1,
          stream_id: job.id,
          data: {
            id:,
            job_id: job.id,
            master_skill_id: master_skill.id
          }
        )
      end
      let(:id) { SecureRandom.uuid }
      let(:job) { create(:job) }
      let(:master_skill) { create(:master_skill) }

      it "creates a desired skill" do
        expect { subject }.to change { DesiredSkill.count }.by(1)

        desired_skill = DesiredSkill.last

        expect(desired_skill.id).to eq(id)
        expect(desired_skill.job_id).to eq(job.id)
        expect(desired_skill.master_skill_id).to eq(master_skill.id)
      end
    end

    context "DesiredSkillDestroyed" do
      let(:message) do
        build(
          :message,
          schema: Events::DesiredSkillDestroyed::V1,
          stream_id: desired_skill.job_id,
          data: {
            id: desired_skill.id
          }
        )
      end
      let!(:desired_skill) { create(:desired_skill) }

      it "destroys a desired skill" do
        expect { subject }.to change { DesiredSkill.count }.by(-1)
      end
    end

    context "JobPhotoCreated" do
      let(:message) do
        build(
          :message,
          schema: Events::JobPhotoCreated::V1,
          stream_id: job.id,
          data: {
            id: SecureRandom.uuid,
            job_id: job.id,
            photo_url: "photo_url"
          }
        )
      end
      let(:job) { create(:job) }

      it "creates a job photo" do
        expect { subject }.to change { JobPhoto.count }.by(1)

        job_photo = JobPhoto.last

        expect(job_photo.id).to eq(message.data[:id])
        expect(job_photo.job_id).to eq(message.data[:job_id])
        expect(job_photo.photo_url).to eq(message.data[:photo_url])
      end
    end

    context "JobPhotoDestroyed" do
      let(:message) do
        build(
          :message,
          schema: Events::JobPhotoDestroyed::V1,
          stream_id: job_photo.job_id,
          data: {
            id: job_photo.id
          }
        )
      end
      let!(:job_photo) { create(:job_photo) }

      it "destroys a job photo" do
        expect { subject }.to change { JobPhoto.count }.by(-1)
      end
    end

    context "TagCreated" do
      let(:message) do
        build(
          :message,
          schema: Events::TagCreated::V1,
          stream_id: SecureRandom.uuid,
          data: {
            name: "BOGO Job"
          }
        )
      end

      it "creates a tag" do
        expect { subject }.to change { Tag.count }.by(1)

        tag = Tag.last

        expect(tag.id).to eq(message.stream.id)
        expect(tag.name).to eq(message.data.name)
      end
    end

    context "JobTagCreated" do
      let(:message) do
        build(
          :message,
          schema: Events::JobTagCreated::V1,
          stream_id: job.id,
          data: {
            id: SecureRandom.uuid,
            job_id: job.id,
            tag_id: tag.id
          }
        )
      end
      let(:job) { create(:job) }
      let(:tag) { create(:tag) }

      it "creates a job tag" do
        expect { subject }.to change { JobTag.count }.by(1)

        job_tag = JobTag.last

        expect(job_tag.id).to eq(message.data[:id])
        expect(job_tag.job_id).to eq(message.data[:job_id])
        expect(job_tag.tag_id).to eq(message.data[:tag_id])
      end
    end

    context "JobTagDestroyed" do
      let(:message) do
        build(
          :message,
          schema: Events::JobTagDestroyed::V2,
          stream_id: job_tag.job_id,
          data: {
            job_id: job_tag.job_id,
            job_tag_id: job_tag.id,
            tag_id: job_tag.tag_id
          }
        )
      end
      let!(:job_tag) { create(:job_tag) }

      it "destroys a job tag" do
        expect { subject }.to change { JobTag.count }.by(-1)
      end
    end

    context "LearnedSkillCreated" do
      let(:message) do
        build(
          :message,
          schema: Events::LearnedSkillCreated::V1,
          stream_id: job.id,
          data: {
            id:,
            job_id: job.id,
            master_skill_id: master_skill.id
          }
        )
      end
      let(:id) { SecureRandom.uuid }
      let(:job) { create(:job) }
      let(:master_skill) { create(:master_skill) }

      it "creates a learned skill" do
        expect { subject }.to change { LearnedSkill.count }.by(1)

        learned_skill = LearnedSkill.last

        expect(learned_skill.id).to eq(id)
        expect(learned_skill.job_id).to eq(job.id)
        expect(learned_skill.master_skill_id).to eq(master_skill.id)
      end
    end

    context "LearnedSkillDestroyed" do
      let(:message) do
        build(
          :message,
          schema: Events::LearnedSkillDestroyed::V1,
          stream_id: learned_skill.job_id,
          data: {
            id: learned_skill.id
          }
        )
      end
      let!(:learned_skill) { create(:learned_skill) }

      it "destroys a learned skill" do
        expect { subject }.to change { LearnedSkill.count }.by(-1)
      end
    end

    context "TestimonialCreated" do
      let(:message) do
        build(
          :message,
          schema: Events::TestimonialCreated::V1,
          stream_id: job.id,
          data: {
            id:,
            job_id: job.id,
            name: "name",
            title: "title",
            testimonial: "testimonial",
            photo_url: "photo_url"
          }
        )
      end
      let(:job) { create(:job) }
      let(:id) { SecureRandom.uuid }

      it "creates a testimonial" do
        expect { subject }.to change { Testimonial.count }.by(1)

        testimonial = Testimonial.last

        expect(testimonial.id).to eq(message.data[:id])
        expect(testimonial.job_id).to eq(message.data[:job_id])
        expect(testimonial.name).to eq(message.data[:name])
        expect(testimonial.title).to eq(message.data[:title])
        expect(testimonial.testimonial).to eq(message.data[:testimonial])
        expect(testimonial.photo_url).to eq(message.data[:photo_url])
      end
    end

    context "TestimonialDestroyed" do
      let(:message) do
        build(
          :message,
          schema: Events::TestimonialDestroyed::V1,
          stream_id: testimonial.job_id,
          data: {
            id: testimonial.id
          }
        )
      end
      let!(:testimonial) { create(:testimonial) }

      it "destroys a testimonial" do
        expect { subject }.to change { Testimonial.count }.by(-1)
      end
    end

    context "EmployerCreated" do
      let(:message) do
        build(
          :message,
          schema: Events::EmployerCreated::V1,
          stream_id: id,
          data: {
            name: "Cool employer",
            location: "The best place",
            bio: "We do great stuff",
            logo_url: "www.google.com"
          }
        )
      end

      it "creates an employer" do
        expect { subject }.to change { Employer.count }.from(0).to(1)

        employer = Employer.last

        expect(employer.id).to eq(id)
        expect(employer.name).to eq(message.data.name)
        expect(employer.location).to eq(message.data.location)
        expect(employer.bio).to eq(message.data.bio)
        expect(employer.logo_url).to eq(message.data.logo_url)
      end
    end

    context "EmployerUpdated" do
      let(:message) do
        build(
          :message,
          schema: Events::EmployerUpdated::V1,
          stream_id: id,
          data: {
            name: "Cool employer",
            location: "The best place",
            bio: "We do great stuff",
            logo_url: "www.google.com"
          }
        )
      end

      let(:id) { employer.id }
      let(:employer) { create(:employer) }

      it "updates a employer" do
        subject

        employer.reload
        expect(employer.name).to eq(message.data.name)
        expect(employer.location).to eq(message.data.location)
        expect(employer.bio).to eq(message.data.bio)
        expect(employer.logo_url).to eq(message.data.logo_url)
      end
    end

    context "JobCreated" do
      let(:message) do
        build(
          :message,
          schema: Events::JobCreated::V3,
          stream_id: id,
          data: {
            category:,
            employer_name:,
            employment_title:,
            employer_id:,
            benefits_description:,
            responsibilities_description:,
            location:,
            employment_type:,
            hide_job:,
            schedule:,
            work_days:,
            requirements_description:,
            industry:
          }
        )
      end
      let(:id) { SecureRandom.uuid }
      let(:category) { Job::Categories::MARKETPLACE }
      let(:employer_name) { "employer" }
      let(:employment_title) { "title" }
      let(:employer_id) { create(:employer).id }
      let(:benefits_description) { "benefits" }
      let(:responsibilities_description) { "responsibilities" }
      let(:location) { "location" }
      let(:employment_type) { Job::EmploymentTypes::FULLTIME }
      let(:hide_job) { false }
      let(:schedule) { "schedule" }
      let(:work_days) { "work_days" }
      let(:requirements_description) { "requirements" }
      let(:industry) { [Job::Industries::MANUFACTURING] }

      it "creates a job" do
        expect { subject }.to change { Job.count }.by(1)

        job = Job.last

        expect(job.id).to eq(id)
        expect(job.employment_title).to eq(employment_title)
        expect(job.employer_id).to eq(employer_id)
        expect(job.benefits_description).to eq(benefits_description)
        expect(job.responsibilities_description).to eq(responsibilities_description)
        expect(job.location).to eq(location)
        expect(job.employment_type).to eq(employment_type)
        expect(job.hide_job).to eq(hide_job)
        expect(job.schedule).to eq(schedule)
        expect(job.work_days).to eq(work_days)
        expect(job.requirements_description).to eq(requirements_description)
        expect(job.industry).to eq(industry)
      end
    end

    context "JobUpdated" do
      let(:message) do
        build(
          :message,
          schema: Events::JobUpdated::V2,
          stream_id: job.id,
          data: {
            category:,
            employment_title:,
            benefits_description:,
            responsibilities_description:,
            location:,
            employment_type:,
            hide_job:,
            schedule:,
            work_days:,
            requirements_description:,
            industry:
          }
        )
      end
      let(:job) { create(:job) }
      let(:category) { Job::Categories::MARKETPLACE }
      let(:employment_title) { "title" }
      let(:benefits_description) { "benefits" }
      let(:responsibilities_description) { "responsibilities" }
      let(:location) { "location" }
      let(:employment_type) { Job::EmploymentTypes::FULLTIME }
      let(:hide_job) { false }
      let(:schedule) { "schedule" }
      let(:work_days) { "work_days" }
      let(:requirements_description) { "requirements" }
      let(:industry) { [Job::Industries::MANUFACTURING] }

      it "updates a job" do
        subject

        expect(job.reload.employment_title).to eq(employment_title)
        expect(job.reload.category).to eq(category)
        expect(job.benefits_description).to eq(benefits_description)
        expect(job.responsibilities_description).to eq(responsibilities_description)
        expect(job.location).to eq(location)
        expect(job.employment_type).to eq(employment_type)
        expect(job.hide_job).to eq(hide_job)
        expect(job.schedule).to eq(schedule)
        expect(job.work_days).to eq(work_days)
        expect(job.requirements_description).to eq(requirements_description)
        expect(job.industry).to eq(industry)
      end
    end

    context "JobAttributeCreated" do
      let(:message) do
        build(
          :message,
          schema: Events::JobAttributeCreated::V1,
          stream_id: job.id,
          data: {
            id:,
            attribute_name: "name",
            attribute_id:,
            acceptible_set: %w[A B]
          }
        )
      end
      let(:id) { SecureRandom.uuid }
      let(:attribute_id) { SecureRandom.uuid }
      let(:job) { create(:job) }

      it "creates a job attribute" do
        expect { subject }.to change { JobAttribute.count }.by(1)

        job_attribute = JobAttribute.last

        expect(job_attribute.id).to eq(id)
        expect(job_attribute.attribute_id).to eq(attribute_id)
        expect(job_attribute.attribute_name).to eq("name")
        expect(job_attribute.acceptible_set).to eq(%w[A B])
      end
    end

    context "JobAttributeUpdated" do
      let(:message) do
        build(
          :message,
          schema: Events::JobAttributeUpdated::V1,
          stream_id: job_attribute.job_id,
          data: {
            id: job_attribute.id,
            acceptible_set: %w[A B]
          }
        )
      end
      let(:job_attribute) { create(:job_attribute, acceptible_set: %w[A]) }

      it "updates a job attribute" do
        subject

        expect(job_attribute.reload.acceptible_set).to eq(%w[A B])
      end
    end

    context "JobAttributeDestroyed" do
      let(:message) do
        build(
          :message,
          schema: Events::JobAttributeDestroyed::V1,
          stream_id: job_attribute.job_id,
          data: {
            id: job_attribute.id
          }
        )
      end
      let(:job_attribute) { create(:job_attribute) }

      it "destroys a job attribute" do
        job_attribute

        expect { subject }.to change { JobAttribute.count }.by(-1)
      end
    end
  end
end

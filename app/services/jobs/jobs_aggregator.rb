module Jobs
  class JobsAggregator < MessageConsumer
    def reset_for_replay
      CareerPath.delete_all
      DesiredCertification.delete_all
      JobPhoto.delete_all
      JobTag.delete_all
      Tag.delete_all
      Testimonial.delete_all
      LearnedSkill.delete_all
      DesiredSkill.delete_all
      JobAttribute.delete_all
      Job.delete_all
      Employer.delete_all
    end

    on_message Events::CareerPathCreated::V1, :sync do |message|
      CareerPath.create!(
        id: message.data.id,
        job_id: message.stream.job_id,
        title: message.data.title,
        lower_limit: message.data.lower_limit,
        upper_limit: message.data.upper_limit,
        order: message.data.order
      )
    end

    on_message Events::CareerPathUpdated::V1, :sync do |message|
      CareerPath.find(message.data.id).update!(order: message.data.order)
    end

    on_message Events::CareerPathDestroyed::V1, :sync do |message|
      CareerPath.find(message.data.id).destroy!
    end

    on_message Events::DesiredCertificationCreated::V1, :sync do |message|
      DesiredCertification.create!(
        id: message.data.id,
        job_id: message.stream.job_id,
        master_certification_id: message.data.master_certification_id
      )
    end

    on_message Events::DesiredCertificationDestroyed::V1, :sync do |message|
      DesiredCertification.find(message.data.id).destroy!
    end

    on_message Events::DesiredSkillCreated::V1, :sync do |message|
      DesiredSkill.create!(
        id: message.data.id,
        job_id: message.stream.job_id,
        master_skill_id: message.data.master_skill_id
      )
    end

    on_message Events::DesiredSkillDestroyed::V1, :sync do |message|
      DesiredSkill.find(message.data.id).destroy!
    end

    on_message Events::JobPhotoCreated::V1, :sync do |message|
      JobPhoto.create!(
        id: message.data.id,
        job_id: message.data.job_id,
        photo_url: message.data.photo_url
      )
    end

    on_message Events::JobPhotoDestroyed::V1, :sync do |message|
      JobPhoto.find(message.data.id).destroy!
    end

    on_message Events::TagCreated::V1 do |message|
      Tag.create!(
        id: message.stream.id,
        name: message.data.name
      )
    end

    on_message Events::JobTagCreated::V1, :sync do |message|
      JobTag.create!(
        id: message.data.id,
        job_id: message.data.job_id,
        tag_id: message.data.tag_id
      )
    end

    on_message Events::JobTagDestroyed::V2, :sync do |message|
      JobTag.find(message.data.job_tag_id).destroy!
    end

    on_message Events::LearnedSkillCreated::V1, :sync do |message|
      LearnedSkill.create!(
        id: message.data.id,
        job_id: message.data.job_id,
        master_skill_id: message.data.master_skill_id
      )
    end

    on_message Events::LearnedSkillDestroyed::V1, :sync do |message|
      LearnedSkill.find(message.data.id).destroy!
    end

    on_message Events::TestimonialCreated::V1, :sync do |message|
      Testimonial.create!(
        id: message.data.id,
        job_id: message.stream.job_id,
        name: message.data.name,
        title: message.data.title,
        testimonial: message.data.testimonial,
        photo_url: message.data.photo_url
      )
    end

    on_message Events::TestimonialDestroyed::V1, :sync do |message|
      Testimonial.find(message.data.id).destroy!
    end

    on_message Events::EmployerCreated::V1 do |message|
      Employer.create!(
        id: message.stream.id,
        name: message.data.name,
        location: message.data.location,
        bio: message.data.bio,
        logo_url: message.data.logo_url
      )
    end

    on_message Events::EmployerUpdated::V1 do |message|
      Employer.update!(
        message.stream.id,
        name: message.data.name,
        location: message.data.location,
        bio: message.data.bio,
        logo_url: message.data.logo_url
      )
    end

    on_message Events::JobCreated::V3, :sync do |message|
      Job.create!(
        id: message.stream.job_id,
        employment_title: message.data.employment_title,
        employer_id: message.data.employer_id,
        benefits_description: message.data.benefits_description,
        responsibilities_description: message.data.responsibilities_description,
        location: message.data.location,
        employment_type: message.data.employment_type,
        hide_job: message.data.hide_job,
        schedule: message.data.schedule,
        work_days: message.data.work_days,
        requirements_description: message.data.requirements_description,
        industry: message.data.industry
      )
    end

    on_message Events::JobUpdated::V2, :sync do |message|
      job = Job.find(message.stream.job_id)

      job.update!(
        employment_title: message.data.employment_title,
        category: message.data.category,
        benefits_description: message.data.benefits_description,
        responsibilities_description: message.data.responsibilities_description,
        location: message.data.location,
        employment_type: message.data.employment_type,
        hide_job: message.data.hide_job,
        schedule: message.data.schedule,
        work_days: message.data.work_days,
        requirements_description: message.data.requirements_description,
        industry: message.data.industry
      )
    end

    on_message Events::JobAttributeCreated::V1, :sync do |message|
      JobAttribute.create!(
        id: message.data.id,
        job_id: message.stream.job_id,
        attribute_name: message.data.attribute_name,
        attribute_id: message.data.attribute_id,
        acceptible_set: message.data.acceptible_set
      )
    end

    on_message Events::JobAttributeUpdated::V1, :sync do |message|
      job_attribute = JobAttribute.find(message.data.id)

      job_attribute.update!(
        acceptible_set: message.data.acceptible_set
      )
    end

    on_message Events::JobAttributeDestroyed::V1, :sync do |message|
      JobAttribute.find(message.data.id).destroy!
    end
  end
end

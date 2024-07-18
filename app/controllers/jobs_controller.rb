class JobsController < ApplicationController
  include Secured
  include MessageEmitter

  before_action :authorize, only: %i[apply elevator_pitch]
  before_action :set_current_user, only: [:show]

  def apply
    if_visible(Job.find(params[:job_id])) do |job|
      with_message_service do
        seeker = current_user.seeker

        Seekers::ApplicationService.apply(job:, seeker:, message_service:)
      end

      head :ok
    end
  end

  def elevator_pitch
    if_visible(Job.find(params[:job_id])) do |job|
      with_message_service do
        Seekers::JobService.new(job:, seeker: current_user.seeker).add_elevator_pitch(params[:elevator_pitch])
      end

      head :accepted
    end
  end

  def show
    if_visible(Job.includes(
      :career_paths,
      :employer,
      :job_photos,
      :testimonials,
      :desired_skills,
      :learned_skills,
      :desired_certifications,
      job_tags: :tag
    ).find(params[:id])) do |job|
      render json: serialize_job(job, current_user&.seeker)
    end
  end

  private

  def if_visible(job, &)
    if job.hide_job
      render json: { error: 'Resource not found' }, status: :not_found
    else
      yield job
    end
  end

  def serialize_job(j, seeker)
    application = Applicant.find_by(job_id: j.id, seeker_id: seeker&.id)
    application_status = application&.status&.status

    {
      **j.slice(
        :id,
        :benefits_description,
        :responsibilities_description,
        :employment_title,
        :location,
        :employment_type,
        :schedule,
        :work_days,
        :requirements_description,
        :category
      ).as_json,
      employer: {
        **j.employer.slice(
          :id,
          :name,
          :location,
          :bio,
          :logo_url,
          :created_at
        ).as_json
      },
      learned_skills: j.learned_skills.map do |ls|
        {
          id: ls.id,
          master_skill: serialize_master_skill(ls.master_skill)
        }
      end.as_json,
      desired_skills: j.desired_skills.map do |ds|
        {
          id: ds.id,
          master_skill: serialize_master_skill(ds.master_skill)
        }
      end.as_json,
      desired_certifications: j.desired_certifications.map do |dc|
        {
          id: dc.id,
          master_certification: serialize_master_certification(dc.master_certification)
        }
      end,
      career_paths: j.career_paths.map { |cp| serialize_career_path(cp) },
      job_photos: j.job_photos.map { |jp| serialize_job_photo(jp) },
      job_tag: j.job_tags.map do |jt|
        {
          id: jt.id,
          tag: {
            id: jt.tag.id,
            name: jt.tag.name
          }
        }
      end,
      application_status:,
      testimonials: j.testimonials.map { |t| serialize_testimonial(t) }
    }
  end

  def serialize_master_skill(master_skill)
    master_skill.slice(:id, :skill, :type)
  end

  def serialize_master_certification(master_certification)
    master_certification.slice(:id, :certification)
  end

  def serialize_career_path(career_paths)
    career_paths.slice(:id, :title, :upper_limit, :lower_limit, :order)
  end

  def serialize_job_photo(job_photo)
    job_photo.slice(:id, :photo_url, :job_id)
  end

  def serialize_testimonial(testimonial)
    testimonial.slice(:id, :name, :title, :testimonial, :photo_url)
  end
end

module JobSearch
  class JobSearchQuery
    def initialize(message_service:)
      @message_service = message_service
    end

    def search(search_terms:, industries:, tags:, user:, utm_source:)
      query = Job.shown.includes(
        :applications,
        :saved_jobs
      )

      query = query.where("lower(employment_title) LIKE ? OR lower(employer_name) LIKE ?", "%#{search_terms.downcase}%", "%#{search_terms.downcase}%") if search_terms_usable?(search_terms)
      query = query.where("industries && ARRAY[?]::character varying[]", industries) if industries_usable?(industries)
      query = query.where("tags && ARRAY[?]::character varying[]", tags) if tags_usable?(tags)

      emit_event(search_terms, industries, tags, user, utm_source)

      serialize(query, user)
    end

    private

    def emit_event(search_terms, industries, tags, user, utm_source)
      if user.present?
        source = if user.seeker.present?
                   "seeker"
                 else
                   "user"
                 end

        search_id = user.id
        metadata = {
          source:,
          id: user.id,
          utm_source:
        }
      else
        search_id = "unauthenticated"
        metadata = {
          source: "unauthenticated",
          utm_source:
        }
      end

      message_service.create!(
        schema: Events::JobSearch::V2,
        data: {
          search_terms:,
          industries:,
          tags:
        },
        search_id:,
        metadata:
      )
    end

    def search_terms_usable?(search_terms)
      search_terms.present? && search_terms.length >= 3
    end

    def industries_usable?(industries)
      industries.present?
    end

    def tags_usable?(tags)
      tags.present?
    end

    def serialize(query, user)
      user_id = user&.id
      seeker_id = user&.seeker&.id

      query.order(category: :desc).map do |job|
        aplication = nil
        saved = nil

        saved = job.saved_jobs.any? { |sj| sj.user_id == user_id } if user_id.present?
        aplication = job.applications.detect { |a| a.seeker_id == seeker_id } if seeker_id.present?

        {
          id: job.job_id,
          category: job.category,
          employment_title: job.employment_title,
          industries: job.industries,
          location: job.location,
          starting_pay: job.starting_upper_pay && {
            employment_type: job.starting_lower_pay.to_i > 1000 ? "salary" : "hourly",
            upper_limit: job.starting_upper_pay,
            lower_limit: job.starting_lower_pay
          },
          tags: job.tags,
          application_status: aplication&.status,
          elevator_pitch: aplication&.elevator_pitch,
          saved:,
          employer: {
            id: job.employer_id,
            name: job.employer_name,
            logo_url: job.employer_logo_url
          }
        }
      end
    end

    attr_reader :message_service
  end
end

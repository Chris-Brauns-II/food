module JobOrders
  class JobOrdersQuery
    def self.all_orders
      JobOrder.for_applicable_jobs.map do |job_order|
        serialize_job_order_summary(job_order)
      end
    end

    def self.all_active_orders
      JobOrder.for_applicable_jobs.active.map do |job_order|
        serialize_job_order_summary(job_order)
      end
    end

    def self.find_order(id)
      serialize_job_order(JobOrder.includes(candidates: :person).find(id))
    end

    def self.all_jobs
      Job.where(applicable_for_job_orders: true).map do |job|
        serialize_job(job)
      end
    end

    class << self
      private

      def serialize_job_order_summary(job_order)
        {
          id: job_order.id,
          employment_title: job_order.job.employment_title,
          employer_name: job_order.job.employer_name,
          opened_at: job_order.opened_at,
          closed_at: job_order.closed_at,
          order_count: job_order.order_count,
          hire_count: job_order.hire_count,
          recommended_count: job_order.recommended_count,
          status: job_order.status,
          job_id: job_order.job.id,
          team_id: job_order.team_id
        }
      end

      def serialize_job_order(job_order)
        candidates = job_order.candidates
        notes = job_order.notes

        {
          **serialize_job_order_summary(job_order),
          benefits_description: job_order.job.benefits_description,
          requirements_description: job_order.job.requirements_description,
          responsibilities_description: job_order.job.responsibilities_description,
          candidates: candidates.map do |candidate|
            {
              id: candidate.id,
              first_name: candidate.person.first_name,
              last_name: candidate.person.last_name,
              phone_number: candidate.person.phone_number,
              email: candidate.person.email,
              applied_at: candidate.applied_at,
              recommended_at: candidate.recommended_at,
              recommended_by: candidate.recommended_by,
              status: candidate.status,
              person_id: candidate.person_id
            }
          end,
          notes: notes.map do |note|
            {
              note: note.note,
              note_id: note.id,
              note_taken_by: note.note_taken_by,
              date: note.note_taken_at
            }
          end
        }
      end

      def serialize_job(job)
        {
          id: job.id,
          employer_name: job.employer_name,
          employer_id: job.employer_id,
          employment_title: job.employment_title
        }
      end
    end
  end
end

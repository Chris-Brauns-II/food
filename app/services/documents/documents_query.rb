module Documents
  module DocumentsQuery
    def self.all_resumes(person_id: nil, requestor_id: nil)
      query = Resume.all

      query = query.where(person_id:) if person_id.present?
      query = query.where(requestor_id:) if requestor_id.present?

      serialize_resume(query)
    end

    def self.all_screeners(person_id: nil)
      query = Screener.all

      query = query.where(person_id:) if person_id.present?

      serialize_screener(query)
    end

    class << self
      private

      def serialize_resume(query)
        query.map do |resume|
          {
            id: resume.id,
            anonymized: resume.anonymized,
            document_status: resume.status,
            generated_at: resume.document_generated_at,
            document_kind: resume.document_kind,
            person_id: resume.person_id
          }
        end
      end

      def serialize_screener(query)
        query.map do |screener|
          {
            id: screener.id,
            document_status: screener.status,
            generated_at: screener.document_generated_at,
            document_kind: screener.document_kind,
            person_id: screener.person_id
          }
        end
      end
    end
  end
end

module JobOrders
  module Projectors
    class JobOrderCriteriaMet
      def project(messages)
        basic_info = Jobs::Projectors::BasicInfo.new.project(messages)
        attributes = Jobs::Projectors::Attributes.new.project(messages).attributes

        return false if basic_info.responsibilities_description.blank?
        return false if basic_info.requirements_description.blank?

        !attributes.empty?
      end
    end
  end
end

class Uuid
  def self.===(other)
    /^[0-9a-fA-F]{8}\b-[0-9a-fA-F]{4}\b-[0-9a-fA-F]{4}\b-[0-9a-fA-F]{4}\b-[0-9a-fA-F]{12}$/ === other # rubocop:disable Style/CaseEquality
  end
end

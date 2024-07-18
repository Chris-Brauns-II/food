class ProfileCompleteness
  Result = Struct.new(:result, :missing)

  def initialize(seeker)
    @seeker = seeker
  end

  def status
    return Result.new("incomplete", %w[education work]) if seeker.nil?

    missing = []

    missing << "education" if missing_education?
    missing << "work" if missing_work?

    Result.new(missing.empty? ? "complete" : "incomplete", missing)
  end

  private

  def missing_education?
    seeker.education_experiences.empty?
  end

  def missing_work?
    seeker.other_experiences.empty?
  end

  attr_reader :seeker
end

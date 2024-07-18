module Events
  module ApplicantScreened
    V1 = Core::Schema.active(
      type: Core::EVENT,
      data: Core::Nothing,
      metadata: Core::Nothing,
      stream: Streams::Application,
      message_type: MessageTypes::Applications::APPLICANT_SCREENED,
      version: 1
    )
  end
end

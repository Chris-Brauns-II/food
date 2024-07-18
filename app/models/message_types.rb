# frozen_string_literal: true

module MessageTypes
  module Applications
    COMMANDS = [
      SCREEN_APPLICANT = 'screen_applicant'
    ].freeze

    EVENTS = [
      APPLICANT_SCREENED = 'applicant_screened'
    ].freeze
  end

  module Attributes
    EVENTS = [
      ATTRIBUTE_CREATED = 'attribute_created',
      ATTRIBUTE_UPDATED = 'attribute_updated',
      ATTRIBUTE_DELETED = 'attribute_deleted'
    ].freeze
  end

  module Qualifications
    EVENTS = [
      MASTER_SKILL_CREATED = 'master_skill_created',
      MASTER_CERTIFICATION_CREATED = 'master_certification_created'
    ].freeze

    COMMANDS = [].freeze
  end

  module Person
    EVENTS = [
      BASIC_INFO_ADDED = 'basic_info_added',
      DATE_OF_BIRTH_ADDED = 'date_of_birth_added',
      EDUCATION_EXPERIENCE_ADDED = 'education_experience_added',
      EDUCATION_EXPERIENCE_DELETED = 'education_experience_deleted',
      ELEVATOR_PITCH_CREATED = 'elevator_pitch_created',
      EXPERIENCE_ADDED = 'experience_added',
      EXPERIENCE_REMOVED = 'experience_removed',
      ONBOARDING_COMPLETED = 'onboarding_completed',
      ONBOARDING_STARTED = 'onboarding_started',
      PERSON_ABOUT_ADDED = 'person_about_added',
      PERSON_ADDED = 'person_added',
      PERSON_ALREADY_ASSOCIATED_TO_USER = 'person_already_associated_to_user',
      PERSON_APPLIED = 'person_applied',
      PERSON_ASSOCIATED_TO_USER = 'person_associated_to_user',
      PERSON_ATTRIBUTE_ADDED = 'person_attribute_added',
      PERSON_ATTRIBUTE_REMOVED = 'person_attribute_removed',
      PERSON_CERTIFIED = 'person_certified',
      PERSON_SOURCED = 'person_sourced',
      PERSON_SKILL_ADDED = 'person_skill_added',
      PERSON_SKILL_REMOVED = 'person_skill_removed',
      PERSON_SKILL_UPDATED = 'person_skill_updated',
      PERSON_VIEWED = 'person_viewed',
      PERSONAL_EXPERIENCE_ADDED = 'personal_experience_added',
      PERSONAL_EXPERIENCE_REMOVED = 'personal_experience_removed',
      PROFESSIONAL_INTERESTS = "professional_interests",
      RELIABILITY_ADDED = 'relability_added',
      STORY_CREATED = 'story_created',
      STORY_DESTROYED = 'story_destroyed',
      STORY_UPDATED = 'story_updated',
      ZIP_ADDED = 'zip_added'
    ].freeze

    COMMANDS = [
      ADD_PERSON = 'add_person',
      COMPLETE_ONBOARDING = 'complete_onboarding',
      START_ONBOARDING = "start_onboarding"
    ].freeze
  end

  module PersonSearch
    EVENTS = [
      PERSON_SEARCH_EXECUTED = 'person_search_executed'
    ].freeze
  end

  module Phone
    EVENTS = [
      PERSON_ASSOCIATED_TO_PHONE_NUMBER = 'person_associated_to_phone_number'
    ].freeze

    COMMANDS = [].freeze
  end

  module Email
    EVENTS = [
      PERSON_ASSOCIATED_TO_EMAIL = 'person_associated_to_email'
    ].freeze

    COMMANDS = [].freeze
  end

  module Coaches
    EVENTS = [
      BARRIER_ADDED = 'barrier_added',
      BARRIERS_UPDATED = 'barriers_updated',
      COACH_ADDED = 'coach_added',
      COACH_ASSIGNED = 'coach_assigned',
      COACH_ASSIGNMENT_WEIGHT_ADDED = 'coach_assignment_weight_added',
      COACH_REMINDER_COMPLETED = 'coach_reminder_completed',
      COACH_REMINDER_SCHEDULED = 'coach_reminder_scheduled',
      JOB_RECOMMENDED = 'job_recommended',
      LEAD_ADDED = 'lead_added',
      NOTE_ADDED = 'note_added',
      NOTE_DELETED = 'note_deleted',
      NOTE_MODIFIED = 'note_modified',
      PERSON_VIEWED_IN_COACHING = 'person_viewed_in_coaching',
      SEEKER_CERTIFIED = 'seeker_certified',
      SKILL_LEVEL_UPDATED = 'skill_level_updated'
    ].freeze

    COMMANDS = [
      ADD_NOTE = "add_note",
      ADD_LEAD = "add_lead",
      ADD_COACH_SEEKER_REMINDER = "add_coach_seeker_reminder",
      ASSIGN_COACH = "assign_coach"
    ].freeze
  end

  module Tags
    EVENTS = [
      TAG_CREATED = 'tag_created'
    ].freeze

    COMMANDS = [].freeze
  end

  module Jobs
    COMMANDS = [
      ADD_DESIRED_CERTIFICATION = "add_desired_certification",
      REMOVE_DESIRED_CERTIFICATION = "remove_desired_certification"
    ].freeze

    EVENTS = [
      CAREER_PATH_CREATED = 'career_path_created',
      CAREER_PATH_UPDATED = 'career_path_updated',
      CAREER_PATH_DESTROYED = 'career_path_destroyed',
      DESIRED_CERTIFICATION_CREATED = 'desired_certification_created',
      DESIRED_CERTIFICATION_DESTROYED = 'desired_certification_destroyed',
      DESIRED_SKILL_CREATED = 'desired_skill_created',
      DESIRED_SKILL_DESTROYED = 'desired_skill_destroyed',
      JOB_ATTRIBUTE_CREATED = 'job_attribute_created',
      JOB_ATTRIBUTE_DESTROYED = 'job_attribute_destroyed',
      JOB_ATTRIBUTE_UPDATED = 'job_attribute_updated',
      JOB_CREATED = 'job_created',
      JOB_UPDATED = 'job_updated',
      JOB_PHOTO_CREATED = 'job_photo_created',
      JOB_PHOTO_DESTROYED = 'job_photo_destroyed',
      LEARNED_SKILL_CREATED = 'learned_skill_created',
      LEARNED_SKILL_DESTROYED = 'learned_skill_destroyed',
      JOB_TAG_CREATED = 'job_tag_created',
      JOB_TAG_DELETED = 'job_tag_deleted',
      PASS_REASON_ADDED = 'pass_reason_added',
      PASS_REASON_REMOVED = 'pass_reason_removed',
      TESTIMONIAL_CREATED = 'testimonial_created',
      TESTIMONIAL_DESTROYED = 'testimonial_destroyed'
    ].freeze
  end

  module Invite
    EVENTS = [
      EMPLOYER_INVITE_CREATED = 'employer_invite_created',
      EMPLOYER_INVITE_ACCEPTED = 'employer_invite_accepted',
      TRAINING_PROVIDER_INVITE_CREATED = 'training_provider_invite_created',
      TRAINING_PROVIDER_INVITE_ACCEPTED = 'training_provider_invite_accepted',
      TRAINING_PROVIDER_INVITE_USED_BY_WRONG_USER = 'training_provider_invite_used_by_wrong_user',
      EMPLOYER_INVITE_USED_BY_WRONG_USER = 'employer_invite_used_by_wrong_user'
    ].freeze

    COMMANDS = [
      CREATE_EMPLOYER_INVITE = 'create_employer_invite',
      ACCEPT_EMPLOYER_INVITE = 'accept_employer_invite',
      CREATE_TRAINING_PROVIDER_INVITE = 'create_training_provider_invite',
      ACCEPT_TRAINING_PROVIDER_INVITE = 'accept_training_provider_invite'
    ].freeze
  end

  module Chats
    EVENTS = [
      CHAT_CREATED = 'chat_created',
      CHAT_MESSAGE_SENT = 'chat_message_sent',
      CHAT_READ = 'chat_read'
    ].freeze

    COMMANDS = [].freeze
  end

  module Employers
    COMMANDS = [
      CREATE_EMPLOYER = 'create_employer',
      UPDATE_EMPLOYER = 'update_employer'
    ].freeze

    EVENTS = [
      EMPLOYER_CREATED = 'employer_created',
      EMPLOYER_UPDATED = 'employer_updated',
      JOB_OWNER_ASSIGNED = 'job_owner_assigned'
    ].freeze
  end

  module Seekers
    COMMANDS = [
      ADD_SEEKER = "add_seeker"
    ].freeze

    EVENTS = [
      EDUCATION_EXPERIENCE_CREATED = 'education_experience_created',
      EDUCATION_EXPERIENCE_UPDATED = 'education_experience_updated',
      EXPERIENCE_CREATED = 'experience_created',
      PERSONAL_EXPERIENCE_CREATED = 'personal_experience_created',
      PROFILE_CREATED = 'profile_created',
      SEEKER_APPLIED = 'seeker_applied',
      SEEKER_ATTRIBUTE_ADDED = 'seeker_attribute_added',
      SEEKER_ATTRIBUTE_REMOVED = 'seeker_attribute_removed',
      SEEKER_CONTEXT_VIEWED = 'seeker_context_viewed',
      SEEKER_CREATED = 'seeker_created',
      SEEKER_SKILL_CREATED = 'seeker_skill_created',
      SEEKER_SKILL_DESTROYED = 'seeker_skill_destroyed',
      SEEKER_SKILL_UPDATED = 'seeker_skill_updated',
      SEEKER_UPDATED = 'seeker_updated',
      SEEKER_VIEWED = 'seeker_viewed',
      USER_BASIC_INFO_ADDED = 'user_basic_info_added'
    ].freeze
  end

  module Contact
    EVENTS = [
      CONTACT_PREFERENCE_SET = "contact_preference_set",
      MESSAGE_SENT = "message_sent",
      MESSAGE_ENQUEUED = "message_enqueued",
      SMS_MESSAGE_SENT = 'sms_sent',
      KLAVIYO_EVENT_PUSHED = "klayvio_event_pushed",
      SLACK_MESSAGE_SENT = "slack_message_sent",
      EMAIL_MESSAGE_SENT = "email_message_sent",
      SMTP_SENT = 'smtp_sent',
      CAL_WEBHOOK_RECEIVED = 'cal_webhook_received',
      SLACK_ID_ADDED = "slack_id_added"
    ].freeze

    COMMANDS = [
      SEND_SMS_MESSAGE = 'send_sms',
      SEND_MESSAGE = "send_message",
      SEND_SLACK_MESSAGE = "send_slack_message",
      SEND_EMAIL_MESSAGE = "send_email_message",
      SET_CONTACT_PREFERENCE = "set_contact_preference",
      NOTIFY_EMPLOYER_OF_APPLICANT = 'notify_employer_of_applicant',
      SEND_WEEKLY_EMPLOYER_UPDATE = 'send_weekly_employer_update'
    ].freeze
  end

  module Infrastructure
    EVENTS = [
      TASK_SCHEDULED = 'task_scheduled',
      TASK_EXECUTED = 'task_executed',
      TASK_CANCELLED = 'task_cancelled'
    ].freeze

    COMMANDS = [
      SCHEDULE_TASK = 'schedule_task',
      CANCEL_TASK = 'cancel_task'
    ].freeze
  end

  module User
    EVENTS = [
      JOB_SAVED = 'job_saved',
      JOB_SEARCH = 'job_search',
      JOB_UNSAVED = 'job_unsaved',
      ROLE_ADDED = 'role_added',
      USER_CREATED = 'user_created',
      USER_UPDATED = 'user_updated'
    ].freeze
  end

  module JobSearch
    EVENTS = [
      JOB_SEARCH = 'job_search'
    ].freeze

    COMMANDS = [].freeze
  end

  module TrainingProviders
    EVENTS = [
      PERSON_TRAINING_PROVIDER_ADDED = 'person_training_provider_added',
      REFERENCE_CREATED = 'reference_created',
      REFERENCE_UPDATED = 'reference_updated',
      SEEKER_TRAINING_PROVIDER_CREATED = 'seeker_training_provider_created',
      TRAINING_PROVIDER_CREATED = 'training_provider_created',
      TRAINING_PROVIDER_PROGRAM_CREATED = 'training_provider_program_created',
      TRAINING_PROVIDER_PROGRAM_UPDATED = 'training_provider_program_updated'
    ].freeze

    COMMANDS = [
      CREATE_TRAINING_PROVIDER = 'create_training_provider',
      CREATE_TRAINING_PROVIDER_PROGRAM = 'create_training_provider_program',
      UPDATE_TRAINING_PROVIDER_PROGRAM = 'update_training_provider_program'
    ].freeze
  end

  # Because our instance amount to singleton
  # if we want to test actual creating an event we need to
  # make it accurate as rspec stubing occurs _after_
  # these schemas have already been generated
  module TestingOnly
    EVENTS = [
      TEST_EVENT_TYPE_DONT_USE_OUTSIDE_OF_TEST = "test_event_type_dont_use_outside_of_test"
    ].freeze
  end

  EVENTS = [
    APPLICANT_STATUS_UPDATED = 'applicant_status_updated',

    DAY_ELAPSED = 'day_elapsed',
    MET_CAREER_COACH_UPDATED = 'met_career_coach_updated',
    NOTIFICATION_CREATED = 'notification_created',
    NOTIFICATIONS_MARKED_READ = 'notifications_marked_read',
    REASON_CREATED = 'reason_created',
    SESSION_STARTED = 'session_started',
    *Documents::MessageTypes::EVENTS,
    *Teams::MessageTypes::EVENTS,
    *Qualifications::EVENTS,
    *Tags::EVENTS,
    *User::EVENTS,
    *Person::EVENTS,
    *PersonSearch::EVENTS,
    *Email::EVENTS,
    *Phone::EVENTS,
    *Attributes::EVENTS,
    *Applications::EVENTS,
    *Coaches::EVENTS,
    *Chats::EVENTS,
    *Jobs::EVENTS,
    *Invite::EVENTS,
    *JobOrders::MessageTypes::EVENTS,
    *Screeners::MessageTypes::EVENTS,
    *Employers::EVENTS,
    *Seekers::EVENTS,
    *Contact::EVENTS,
    *JobSearch::EVENTS,
    *Infrastructure::EVENTS,
    *TestingOnly::EVENTS,
    *TrainingProviders::EVENTS
  ].freeze

  COMMANDS = [
    *Documents::MessageTypes::COMMANDS,
    *Teams::MessageTypes::COMMANDS,
    *Qualifications::COMMANDS,
    *Applications::COMMANDS,
    *Tags::COMMANDS,
    *Person::COMMANDS,
    *Email::COMMANDS,
    *Jobs::COMMANDS,
    *Employers::COMMANDS,
    *Phone::COMMANDS,
    *TrainingProviders::COMMANDS,
    *Contact::COMMANDS,
    *Chats::COMMANDS,
    *Coaches::COMMANDS,
    *Seekers::COMMANDS,
    *Invite::COMMANDS,
    *JobOrders::MessageTypes::COMMANDS,
    *Screeners::MessageTypes::COMMANDS,
    *JobSearch::COMMANDS,
    *Infrastructure::COMMANDS
  ].freeze

  ALL = [
    *EVENTS,
    *COMMANDS
  ].freeze
end

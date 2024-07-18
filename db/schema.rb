# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# This file is the source Rails uses to define your schema when running `bin/rails
# db:schema:load`. When creating a new database, `bin/rails db:schema:load` tends to
# be faster and is potentially less error prone than running all of your
# migrations from scratch. Old migrations may fail to apply correctly if those
# migrations use external dependencies or application code.
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema[7.1].define(version: 2024_07_16_155205) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  # Custom types defined in this database.
  # Note that some types may not work with other database engines. Be careful if changing database.
  create_enum "employment_type", ["FULLTIME", "PARTTIME"]
  create_enum "skill_type", ["PERSONAL", "TECHNICAL"]
  create_enum "user_type", ["SEEKER", "TRAINING_PROVIDER"]

  create_table "accounts", id: :text, force: :cascade do |t|
    t.text "user_id", null: false
    t.text "type", null: false
    t.text "provider", null: false
    t.text "provider_account_id", null: false
    t.text "refresh_token"
    t.text "access_token"
    t.integer "expires_at"
    t.text "token_type"
    t.text "scope"
    t.text "id_token"
    t.text "session_state"
    t.datetime "created_at", precision: 3, default: -> { "CURRENT_TIMESTAMP" }, null: false
    t.datetime "updated_at", precision: 3, null: false
    t.index ["provider", "provider_account_id"], name: "Account_provider_provider_account_id_key", unique: true
  end

  create_table "analytics_dim_employers", force: :cascade do |t|
    t.string "name", null: false
    t.uuid "employer_id", null: false
    t.index ["employer_id"], name: "index_analytics_dim_employers_on_employer_id", unique: true
  end

  create_table "analytics_dim_job_orders", force: :cascade do |t|
    t.bigint "analytics_dim_jobs_id", null: false
    t.uuid "job_order_id", null: false
    t.integer "order_count"
    t.datetime "order_opened_at", null: false
    t.datetime "closed_at"
    t.string "closed_status"
    t.string "employer_name"
    t.string "employment_title"
    t.index ["analytics_dim_jobs_id"], name: "index_analytics_dim_job_orders_on_analytics_dim_jobs_id"
    t.index ["job_order_id"], name: "index_analytics_dim_job_orders_on_job_order_id", unique: true
  end

  create_table "analytics_dim_jobs", force: :cascade do |t|
    t.datetime "job_created_at", null: false
    t.uuid "job_id", null: false
    t.string "category", null: false
    t.string "employment_type", null: false
    t.string "employment_title", null: false
    t.bigint "analytics_dim_employer_id", null: false
    t.string "employer_name"
    t.index ["analytics_dim_employer_id"], name: "index_analytics_dim_jobs_on_analytics_dim_employer_id"
    t.index ["employment_type"], name: "index_analytics_dim_jobs_on_employment_type"
    t.index ["job_id"], name: "index_analytics_dim_jobs_on_job_id", unique: true
  end

  create_table "analytics_dim_people", force: :cascade do |t|
    t.string "first_name"
    t.string "last_name"
    t.string "phone_number"
    t.string "email"
    t.string "kind", null: false
    t.datetime "onboarding_completed_at"
    t.uuid "person_id", null: false
    t.bigint "analytics_dim_user_id"
    t.datetime "person_added_at", null: false
    t.index ["analytics_dim_user_id"], name: "index_analytics_dim_people_on_analytics_dim_user_id"
    t.index ["email"], name: "index_analytics_dim_people_on_email"
    t.index ["kind"], name: "index_analytics_dim_people_on_kind"
    t.index ["person_id"], name: "index_analytics_dim_people_on_person_id", unique: true
    t.index ["phone_number"], name: "index_analytics_dim_people_on_phone_number"
  end

  create_table "analytics_dim_users", force: :cascade do |t|
    t.string "user_id", null: false
    t.string "email"
    t.string "first_name"
    t.string "last_name"
    t.datetime "user_created_at", precision: nil, null: false
    t.datetime "last_active_at"
    t.string "kind"
    t.uuid "coach_id"
    t.index ["coach_id"], name: "index_analytics_dim_users_on_coach_id", unique: true
    t.index ["user_id"], name: "index_analytics_dim_users_on_user_id", unique: true
  end

  create_table "analytics_fact_applications", force: :cascade do |t|
    t.bigint "analytics_dim_job_id", null: false
    t.bigint "analytics_dim_person_id", null: false
    t.uuid "application_id", null: false
    t.datetime "application_opened_at", null: false
    t.string "status", null: false
    t.integer "application_number", null: false
    t.datetime "application_updated_at"
    t.index ["analytics_dim_job_id"], name: "index_analytics_fact_applications_on_analytics_dim_job_id"
    t.index ["analytics_dim_person_id"], name: "index_analytics_fact_applications_on_analytics_dim_person_id"
    t.index ["application_id"], name: "index_analytics_fact_applications_on_application_id"
    t.index ["application_number"], name: "index_analytics_fact_applications_on_application_number"
    t.index ["status"], name: "index_analytics_fact_applications_on_status"
  end

  create_table "analytics_fact_candidates", force: :cascade do |t|
    t.bigint "analytics_dim_people_id", null: false
    t.bigint "analytics_dim_job_orders_id", null: false
    t.integer "order_candidate_number", null: false
    t.datetime "added_at", null: false
    t.datetime "terminal_status_at"
    t.string "status", null: false
    t.string "employer_name"
    t.string "employment_title"
    t.string "first_name"
    t.string "last_name"
    t.string "email"
    t.index ["analytics_dim_job_orders_id"], name: "index_analytics_fact_candidates_on_analytics_dim_job_orders_id"
    t.index ["analytics_dim_people_id"], name: "index_analytics_fact_candidates_on_analytics_dim_people_id"
  end

  create_table "analytics_fact_coach_actions", force: :cascade do |t|
    t.bigint "analytics_dim_person_target_id"
    t.string "action", null: false
    t.datetime "action_taken_at", null: false
    t.bigint "analytics_dim_users_id", null: false
    t.index ["action"], name: "index_analytics_fact_coach_actions_on_action"
    t.index ["analytics_dim_person_target_id"], name: "idx_on_analytics_dim_person_target_id_a665f20399"
    t.index ["analytics_dim_users_id"], name: "index_analytics_fact_coach_actions_on_analytics_dim_users_id"
  end

  create_table "analytics_fact_job_visibilities", force: :cascade do |t|
    t.bigint "analytics_dim_job_id", null: false
    t.datetime "visible_starting_at", null: false
    t.datetime "visible_ending_at"
    t.index ["analytics_dim_job_id"], name: "index_analytics_fact_job_visibilities_on_analytics_dim_job_id"
  end

  create_table "analytics_fact_person_vieweds", force: :cascade do |t|
    t.bigint "analytics_dim_person_viewed_id", null: false
    t.datetime "viewed_at", null: false
    t.string "viewing_context", null: false
    t.bigint "analytics_dim_user_viewer_id"
    t.index ["analytics_dim_person_viewed_id"], name: "idx_on_analytics_dim_person_viewed_id_15c412a0ed"
    t.index ["analytics_dim_user_viewer_id"], name: "idx_on_analytics_dim_user_viewer_id_701fd02455"
  end

  create_table "applicant_statuses", id: :text, force: :cascade do |t|
    t.text "applicant_id", null: false
    t.text "status", null: false
    t.datetime "created_at", precision: 3, default: -> { "CURRENT_TIMESTAMP" }, null: false
    t.datetime "updated_at", precision: 3, null: false
  end

  create_table "applicants", id: :text, force: :cascade do |t|
    t.text "job_id", null: false
    t.datetime "created_at", precision: 3, default: -> { "CURRENT_TIMESTAMP" }, null: false
    t.datetime "updated_at", precision: 3, null: false
    t.uuid "seeker_id", null: false
    t.string "elevator_pitch"
    t.index ["job_id"], name: "index_applicants_on_job_id"
    t.index ["seeker_id"], name: "index_applicants_on_seeker_id"
  end

  create_table "attributes_attributes", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.string "name", null: false
    t.text "description"
    t.string "set", null: false, array: true
    t.string "default", null: false, array: true
  end

  create_table "barriers", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.string "name", null: false
    t.uuid "barrier_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["barrier_id"], name: "index_barriers_on_barrier_id", unique: true
  end

  create_table "career_paths", id: :text, force: :cascade do |t|
    t.text "title", null: false
    t.text "upper_limit", null: false
    t.text "lower_limit", null: false
    t.integer "order", null: false
    t.text "job_id", null: false
    t.datetime "created_at", precision: 3, default: -> { "CURRENT_TIMESTAMP" }, null: false
    t.datetime "updated_at", precision: 3, null: false
  end

  create_table "chats_applicant_chats", force: :cascade do |t|
    t.uuid "application_id", null: false
    t.uuid "employer_id", null: false
    t.uuid "seeker_id", null: false
    t.string "title", null: false
    t.datetime "chat_created_at", null: false
    t.datetime "chat_updated_at", null: false
    t.index ["application_id"], name: "index_chats_applicant_chats_on_application_id"
    t.index ["employer_id"], name: "index_chats_applicant_chats_on_employer_id"
    t.index ["seeker_id"], name: "index_chats_applicant_chats_on_seeker_id"
  end

  create_table "chats_messages", force: :cascade do |t|
    t.bigint "chats_applicant_chats_id", null: false
    t.string "from", null: false
    t.string "user_id"
    t.string "message", null: false
    t.datetime "message_sent_at", null: false
    t.index ["chats_applicant_chats_id"], name: "index_chats_messages_on_chats_applicant_chats_id"
  end

  create_table "chats_read_receipts", force: :cascade do |t|
    t.bigint "chats_applicant_chats_id", null: false
    t.string "user_id", null: false
    t.datetime "read_until", null: false
    t.index ["chats_applicant_chats_id"], name: "index_chats_read_receipts_on_chats_applicant_chats_id"
    t.index ["user_id"], name: "index_chats_read_receipts_on_user_id"
  end

  create_table "coaches_coaches", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.float "assignment_weight", null: false
    t.string "email"
    t.string "user_id", null: false
    t.index ["user_id"], name: "index_coaches_coaches_on_user_id"
  end

  create_table "coaches_feed_events", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.string "context_id", null: false
    t.string "seeker_email", null: false
    t.text "description", null: false
    t.datetime "occurred_at", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "coaches_jobs", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.uuid "job_id", null: false
    t.string "employment_title", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "employer_name"
    t.boolean "hide_job", default: false, null: false
    t.index ["job_id"], name: "index_coaches_jobs_on_job_id"
  end

  create_table "coaches_person_applications", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.uuid "coaches_person_context_id", null: false
    t.string "employer_name", null: false
    t.string "employment_title", null: false
    t.string "status", null: false
    t.uuid "job_id", null: false
    t.index ["coaches_person_context_id"], name: "index_coaches_person_applications_on_coaches_person_context_id"
  end

  create_table "coaches_person_attributes", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.uuid "coaches_person_context_id", null: false
    t.uuid "attribute_id", null: false
    t.string "name", null: false
    t.string "values", default: [], array: true
    t.index ["coaches_person_context_id"], name: "index_coaches_person_attributes_on_coaches_person_context_id"
  end

  create_table "coaches_person_contexts", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.string "assigned_coach"
    t.string "certified_by"
    t.string "email"
    t.string "phone_number"
    t.string "first_name"
    t.string "last_name"
    t.string "kind", null: false
    t.datetime "person_captured_at", null: false
    t.datetime "last_active_on"
    t.datetime "last_contacted_at"
    t.uuid "barriers", default: [], array: true
    t.string "captured_by"
    t.string "user_id"
    t.index ["kind"], name: "index_coaches_person_contexts_on_kind"
    t.index ["user_id"], name: "index_coaches_person_contexts_on_user_id"
  end

  create_table "coaches_person_job_recommendations", force: :cascade do |t|
    t.uuid "coaches_coaches_id", null: false
    t.uuid "coaches_person_contexts_id", null: false
    t.uuid "coaches_jobs_id", null: false
    t.index ["coaches_coaches_id"], name: "index_coaches_person_job_recommendations_on_coaches_coaches_id"
    t.index ["coaches_jobs_id"], name: "index_coaches_person_job_recommendations_on_coaches_jobs_id"
    t.index ["coaches_person_contexts_id"], name: "idx_on_coaches_person_contexts_id_5ae9369261"
  end

  create_table "coaches_person_notes", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.uuid "coaches_person_context_id", null: false
    t.text "note", null: false
    t.datetime "note_taken_at", null: false
    t.string "note_taken_by", null: false
    t.index ["coaches_person_context_id"], name: "index_coaches_person_notes_on_coaches_person_context_id"
  end

  create_table "coaches_reminders", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.uuid "coaches_coaches_id", null: false
    t.text "note", null: false
    t.datetime "reminder_at", null: false
    t.string "state", null: false
    t.uuid "message_task_id", null: false
    t.uuid "person_id"
    t.index ["coaches_coaches_id"], name: "index_coaches_reminders_on_coaches_coaches_id"
  end

  create_table "contact_notifications", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.text "user_id", null: false
    t.string "body"
    t.string "title"
    t.string "url"
    t.datetime "read_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["user_id"], name: "index_contact_notifications_on_user_id"
  end

  create_table "credentials", id: :text, force: :cascade do |t|
    t.text "organization_id"
    t.text "name"
    t.text "description"
    t.datetime "created_at", precision: 3, default: -> { "CURRENT_TIMESTAMP" }, null: false
    t.datetime "updated_at", precision: 3, null: false
    t.text "issued_date"
    t.uuid "seeker_id", null: false
  end

  create_table "desired_certifications", id: :text, force: :cascade do |t|
    t.text "master_certification_id", null: false
    t.text "job_id", null: false
    t.datetime "created_at", precision: 3, default: -> { "CURRENT_TIMESTAMP" }, null: false
    t.datetime "updated_at", precision: 3, null: false
  end

  create_table "desired_skills", id: :text, force: :cascade do |t|
    t.text "master_skill_id", null: false
    t.text "job_id", null: false
    t.datetime "created_at", precision: 3, default: -> { "CURRENT_TIMESTAMP" }, null: false
    t.datetime "updated_at", precision: 3, null: false
  end

  create_table "documents", id: :text, force: :cascade do |t|
    t.string "file_name", null: false
    t.binary "file_data", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "documents_resumes", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.string "document_kind", null: false
    t.string "requestor_type", null: false
    t.string "requestor_id", null: false
    t.uuid "person_id", null: false
    t.boolean "anonymized", null: false
    t.string "status", null: false
    t.string "storage_kind"
    t.string "storage_identifier"
    t.datetime "document_generated_at"
    t.index ["person_id"], name: "index_documents_resumes_on_person_id"
    t.index ["requestor_id"], name: "index_documents_resumes_on_requestor_id"
  end

  create_table "documents_screeners", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.datetime "document_generated_at"
    t.string "document_kind", null: false
    t.string "requestor_type", null: false
    t.string "status", null: false
    t.string "storage_identifier"
    t.string "storage_kind"
    t.string "requestor_id", null: false
    t.uuid "screener_answers_id", null: false
    t.uuid "person_id"
    t.index ["person_id"], name: "index_documents_screeners_on_person_id"
    t.index ["requestor_id"], name: "index_documents_screeners_on_requestor_id"
    t.index ["screener_answers_id"], name: "index_documents_screeners_on_screener_answers_id"
  end

  create_table "education_experiences", id: :text, force: :cascade do |t|
    t.text "organization_id"
    t.text "organization_name"
    t.text "title"
    t.text "activities"
    t.text "graduation_date"
    t.text "gpa"
    t.datetime "created_at", precision: 3, default: -> { "CURRENT_TIMESTAMP" }, null: false
    t.datetime "updated_at", precision: 3, null: false
    t.uuid "seeker_id", null: false
    t.index ["seeker_id"], name: "index_education_experiences_on_seeker_id"
  end

  create_table "employer_invites", id: :text, force: :cascade do |t|
    t.text "email", null: false
    t.text "first_name", null: false
    t.text "last_name", null: false
    t.text "employer_id", null: false
    t.datetime "used_at", precision: 3
    t.datetime "created_at", precision: 3, default: -> { "CURRENT_TIMESTAMP" }, null: false
    t.datetime "updated_at", precision: 3, null: false
  end

  create_table "employers", id: :text, force: :cascade do |t|
    t.text "name", null: false
    t.text "location"
    t.text "bio", null: false
    t.text "logo_url"
    t.datetime "created_at", precision: 3, default: -> { "CURRENT_TIMESTAMP" }, null: false
    t.datetime "updated_at", precision: 3, null: false
    t.boolean "chat_enabled", default: false, null: false
  end

  create_table "employers_applicants", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.string "applicant_id", null: false
    t.uuid "seeker_id", null: false
    t.string "first_name", null: false
    t.string "last_name", null: false
    t.string "email", null: false
    t.string "phone_number"
    t.string "status", null: false
    t.uuid "employers_job_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.datetime "status_as_of"
    t.string "certified_by"
    t.datetime "application_submit_at"
    t.string "status_reason"
    t.index ["applicant_id"], name: "index_employers_applicants_on_applicant_id", unique: true
    t.index ["employers_job_id"], name: "index_employers_applicants_on_employers_job_id"
    t.index ["seeker_id"], name: "index_employers_applicants_on_seeker_id"
  end

  create_table "employers_employers", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.string "name", null: false
    t.string "location"
    t.string "bio", null: false
    t.string "logo_url"
    t.string "employer_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "employers_job_owners", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.uuid "employers_recruiter_id", null: false
    t.uuid "employers_job_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["employers_job_id"], name: "index_employers_job_owners_on_employers_job_id"
    t.index ["employers_recruiter_id"], name: "index_employers_job_owners_on_employers_recruiter_id"
  end

  create_table "employers_jobs", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.string "job_id", null: false
    t.string "employment_title", null: false
    t.string "benefits_description", null: false
    t.string "employment_type", null: false
    t.boolean "hide_job", default: false, null: false
    t.string "industry", default: [], array: true
    t.string "location", null: false
    t.string "requirements_description"
    t.string "responsibilities_description"
    t.string "schedule"
    t.string "work_days"
    t.uuid "employers_employer_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.text "elevator_pitch"
    t.string "category", default: "marketplace", null: false
    t.index ["employers_employer_id"], name: "index_employers_jobs_on_employers_employer_id"
  end

  create_table "employers_recruiters", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.uuid "employers_employer_id", null: false
    t.string "email", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["email"], name: "index_employers_recruiters_on_email", unique: true
    t.index ["employers_employer_id"], name: "index_employers_recruiters_on_employers_employer_id"
  end

  create_table "employers_seekers", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.uuid "seeker_id", null: false
    t.string "certified_by"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["seeker_id"], name: "index_employers_seekers_on_seeker_id"
  end

  create_table "events", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.string "aggregate_id", null: false
    t.string "event_type", null: false
    t.jsonb "data", default: {}, null: false
    t.jsonb "metadata", default: {}, null: false
    t.integer "version", default: 0, null: false
    t.datetime "occurred_at", default: -> { "CURRENT_TIMESTAMP" }, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.uuid "trace_id", null: false
    t.index ["aggregate_id"], name: "index_events_on_aggregate_id"
    t.index ["event_type", "version"], name: "index_events_on_event_type_and_version"
    t.index ["event_type"], name: "index_events_on_event_type"
    t.index ["occurred_at"], name: "index_events_on_occurred_at"
    t.index ["trace_id"], name: "index_events_on_trace_id"
  end

  create_table "flipper_features", force: :cascade do |t|
    t.string "key", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["key"], name: "index_flipper_features_on_key", unique: true
  end

  create_table "flipper_gates", force: :cascade do |t|
    t.string "feature_key", null: false
    t.string "key", null: false
    t.string "value"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["feature_key", "key", "value"], name: "index_flipper_gates_on_feature_key_and_key_and_value", unique: true
  end

  create_table "infrastructure_tasks", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.datetime "execute_at", null: false
    t.string "state", null: false
    t.jsonb "command", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["execute_at"], name: "index_infrastructure_tasks_on_execute_at"
    t.index ["state"], name: "index_infrastructure_tasks_on_state"
  end

  create_table "invites_employer_invites", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.string "email", null: false
    t.string "first_name", null: false
    t.string "last_name", null: false
    t.datetime "used_at"
    t.uuid "employer_id", null: false
    t.string "employer_name", null: false
  end

  create_table "invites_training_provider_invites", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.string "email", null: false
    t.string "first_name", null: false
    t.string "last_name", null: false
    t.datetime "used_at"
    t.uuid "training_provider_id", null: false
    t.string "training_provider_name", null: false
    t.string "role_description", null: false
  end

  create_table "job_attributes", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.text "job_id", null: false
    t.string "acceptible_set", default: [], null: false, array: true
    t.uuid "attribute_id", null: false
    t.string "attribute_name", null: false
    t.index ["job_id"], name: "index_job_attributes_on_job_id"
  end

  create_table "job_freshness_contexts", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.jsonb "applicants", default: {}, null: false
    t.string "employer_name", null: false
    t.string "employment_title", null: false
    t.boolean "hidden", default: false, null: false
    t.uuid "job_id", null: false
    t.boolean "recruiter_exists", default: false, null: false
    t.string "status", default: "fresh", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "job_freshness_employer_jobs", force: :cascade do |t|
    t.string "employer_id", null: false
    t.boolean "recruiter_exists", default: false, null: false
    t.string "jobs", default: [], null: false, array: true
    t.string "name", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "job_freshnesses", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.uuid "job_id"
    t.string "status"
    t.string "employment_title"
    t.string "employer_name"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.datetime "occurred_at", null: false
  end

  create_table "job_orders_candidates", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.uuid "job_orders_job_orders_id", null: false
    t.uuid "job_orders_people_id", null: false
    t.string "status", null: false
    t.datetime "added_at", null: false
    t.datetime "applied_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.datetime "recommended_at"
    t.datetime "status_updated_at"
    t.string "recommended_by"
    t.index ["job_orders_job_orders_id"], name: "index_job_orders_candidates_on_job_orders_job_orders_id"
    t.index ["job_orders_people_id"], name: "index_job_orders_candidates_on_job_orders_people_id"
  end

  create_table "job_orders_job_orders", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.uuid "job_orders_jobs_id", null: false
    t.integer "candidate_count", null: false
    t.integer "applicant_count", null: false
    t.integer "recommended_count", null: false
    t.integer "hire_count", null: false
    t.integer "order_count"
    t.datetime "closed_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "status", null: false
    t.datetime "opened_at", null: false
    t.integer "screened_count"
    t.uuid "team_id"
    t.index ["job_orders_jobs_id"], name: "index_job_orders_job_orders_on_job_orders_jobs_id"
    t.index ["status"], name: "index_job_orders_job_orders_on_status"
  end

  create_table "job_orders_jobs", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.string "employment_title", null: false
    t.string "employer_name", null: false
    t.uuid "employer_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.boolean "applicable_for_job_orders"
    t.text "benefits_description"
    t.text "requirements_description"
    t.text "responsibilities_description"
    t.index ["employer_id"], name: "index_job_orders_jobs_on_employer_id"
  end

  create_table "job_orders_notes", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.uuid "job_orders_job_orders_id", null: false
    t.datetime "note_taken_at", null: false
    t.string "note_taken_by", null: false
    t.string "note", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["job_orders_job_orders_id"], name: "index_job_orders_notes_on_job_orders_job_orders_id"
  end

  create_table "job_orders_people", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.string "email"
    t.string "phone_number"
    t.string "first_name"
    t.string "last_name"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "job_orders_status_owners", force: :cascade do |t|
    t.string "order_status", null: false
    t.uuid "team_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["order_status"], name: "index_job_orders_status_owners_on_order_status", unique: true
  end

  create_table "job_photos", id: :text, force: :cascade do |t|
    t.text "photo_url", null: false
    t.text "job_id", null: false
    t.datetime "created_at", precision: 3, default: -> { "CURRENT_TIMESTAMP" }, null: false
    t.datetime "updated_at", precision: 3, null: false
  end

  create_table "job_tags", id: :text, force: :cascade do |t|
    t.text "job_id", null: false
    t.text "tag_id", null: false
    t.datetime "created_at", precision: 3, default: -> { "CURRENT_TIMESTAMP" }, null: false
    t.datetime "updated_at", precision: 3, null: false
  end

  create_table "jobs", id: :text, force: :cascade do |t|
    t.text "employer_id", null: false
    t.text "benefits_description", null: false
    t.text "responsibilities_description"
    t.text "employment_title", null: false
    t.text "location", null: false
    t.enum "employment_type", null: false, enum_type: "employment_type"
    t.boolean "hide_job", default: false, null: false
    t.text "schedule"
    t.text "work_days"
    t.text "requirements_description"
    t.datetime "created_at", precision: 3, default: -> { "CURRENT_TIMESTAMP" }, null: false
    t.datetime "updated_at", precision: 3, null: false
    t.text "industry", default: [], array: true
    t.string "category", default: "marketplace"
  end

  create_table "learned_skills", id: :text, force: :cascade do |t|
    t.text "master_skill_id", null: false
    t.text "job_id", null: false
    t.datetime "created_at", precision: 3, default: -> { "CURRENT_TIMESTAMP" }, null: false
    t.datetime "updated_at", precision: 3, null: false
  end

  create_table "listener_bookmarks", force: :cascade do |t|
    t.string "consumer_name", null: false
    t.uuid "event_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.datetime "current_timestamp", null: false
    t.index ["consumer_name"], name: "index_listener_bookmarks_on_consumer_name", unique: true
  end

  create_table "master_certifications", id: :text, force: :cascade do |t|
    t.text "certification", null: false
    t.datetime "created_at", precision: 3, default: -> { "CURRENT_TIMESTAMP" }, null: false
    t.datetime "updated_at", precision: 3, null: false
  end

  create_table "master_skills", id: :text, force: :cascade do |t|
    t.text "skill", null: false
    t.enum "type", null: false, enum_type: "skill_type"
    t.datetime "created_at", precision: 3, default: -> { "CURRENT_TIMESTAMP" }, null: false
    t.datetime "updated_at", precision: 3, null: false
  end

  create_table "onboarding_sessions", id: :text, force: :cascade do |t|
    t.datetime "started_at", precision: 3, null: false
    t.datetime "completed_at", precision: 3
    t.datetime "created_at", precision: 3, default: -> { "CURRENT_TIMESTAMP" }, null: false
    t.datetime "updated_at", precision: 3, null: false
    t.jsonb "responses", default: {}, null: false
    t.uuid "seeker_id", null: false
    t.index ["seeker_id"], name: "index_onboarding_sessions_on_seeker_id", unique: true
  end

  create_table "organizations", id: :text, force: :cascade do |t|
    t.text "name", null: false
    t.text "image"
    t.datetime "created_at", precision: 3, default: -> { "CURRENT_TIMESTAMP" }, null: false
    t.datetime "updated_at", precision: 3, null: false
  end

  create_table "other_experiences", id: :text, force: :cascade do |t|
    t.text "organization_id"
    t.text "organization_name"
    t.text "start_date"
    t.boolean "is_current"
    t.text "end_date"
    t.text "description"
    t.text "position"
    t.datetime "created_at", precision: 3, default: -> { "CURRENT_TIMESTAMP" }, null: false
    t.datetime "updated_at", precision: 3, null: false
    t.uuid "seeker_id", null: false
    t.index ["seeker_id"], name: "index_other_experiences_on_seeker_id"
  end

  create_table "people_search_coaches", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.string "email", null: false
  end

  create_table "people_search_people", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.string "email"
    t.string "assigned_coach"
    t.string "first_name"
    t.string "last_name"
    t.string "phone_number"
    t.date "date_of_birth"
    t.text "search_vector", null: false
    t.string "certified_by"
    t.datetime "last_active_at"
    t.datetime "last_contacted_at"
    t.string "user_id"
  end

  create_table "people_search_person_education_experiences", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.uuid "person_id", null: false
    t.string "organization_name"
    t.string "title"
    t.text "activities"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["person_id"], name: "index_people_search_person_education_experiences_on_person_id"
  end

  create_table "people_search_person_experiences", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.uuid "person_id", null: false
    t.string "organization_name"
    t.string "position"
    t.text "description"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["person_id"], name: "index_people_search_person_experiences_on_person_id"
  end

  create_table "personal_experiences", id: :text, force: :cascade do |t|
    t.text "activity"
    t.text "start_date"
    t.text "end_date"
    t.text "description"
    t.datetime "created_at", precision: 3, default: -> { "CURRENT_TIMESTAMP" }, null: false
    t.datetime "updated_at", precision: 3, null: false
    t.uuid "seeker_id", null: false
    t.index ["seeker_id"], name: "index_personal_experiences_on_seeker_id"
  end

  create_table "profile_skills", id: :text, force: :cascade do |t|
    t.text "master_skill_id", null: false
    t.text "description"
    t.datetime "created_at", precision: 3, default: -> { "CURRENT_TIMESTAMP" }, null: false
    t.datetime "updated_at", precision: 3, null: false
    t.uuid "seeker_id", null: false
    t.index ["seeker_id"], name: "index_profile_skills_on_seeker_id"
  end

  create_table "profiles", id: :text, force: :cascade do |t|
    t.text "user_id", null: false
    t.text "bio"
    t.text "image"
    t.text "status"
    t.datetime "created_at", precision: 3, default: -> { "CURRENT_TIMESTAMP" }, null: false
    t.datetime "updated_at", precision: 3, null: false
    t.boolean "met_career_coach", default: false
    t.index ["user_id"], name: "Profile_user_id_key", unique: true
  end

  create_table "programs", id: :text, force: :cascade do |t|
    t.text "name", null: false
    t.text "description", null: false
    t.text "training_provider_id", null: false
    t.datetime "created_at", precision: 3, default: -> { "CURRENT_TIMESTAMP" }, null: false
    t.datetime "updated_at", precision: 3, null: false
  end

  create_table "reasons", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.string "description"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "recruiters", id: :text, force: :cascade do |t|
    t.text "user_id", null: false
    t.text "employer_id", null: false
    t.datetime "created_at", precision: 3, default: -> { "CURRENT_TIMESTAMP" }, null: false
    t.datetime "updated_at", precision: 3, null: false
  end

  create_table "screeners_answers", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.string "title", null: false
    t.jsonb "question_responses", null: false
    t.uuid "screeners_questions_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.uuid "person_id", null: false
    t.index ["screeners_questions_id"], name: "index_screeners_answers_on_screeners_questions_id"
  end

  create_table "screeners_questions", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.string "title", null: false
    t.jsonb "questions", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "search_applications", force: :cascade do |t|
    t.string "status", null: false
    t.uuid "application_id", null: false
    t.uuid "seeker_id", null: false
    t.uuid "job_id", null: false
    t.text "elevator_pitch"
    t.bigint "search_job_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["application_id"], name: "index_search_applications_on_application_id"
    t.index ["search_job_id"], name: "index_search_applications_on_search_job_id"
    t.index ["seeker_id"], name: "index_search_applications_on_seeker_id"
  end

  create_table "search_employers", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.text "logo_url"
  end

  create_table "search_jobs", force: :cascade do |t|
    t.uuid "job_id", null: false
    t.boolean "hidden", default: false, null: false
    t.string "employment_title", null: false
    t.string "industries", default: [], array: true
    t.string "category", null: false
    t.text "location", null: false
    t.string "employment_type", null: false
    t.integer "starting_upper_pay"
    t.integer "starting_lower_pay"
    t.string "tags", default: [], array: true
    t.uuid "employer_id", null: false
    t.string "employer_name", null: false
    t.text "employer_logo_url"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["employer_name"], name: "index_search_jobs_on_employer_name"
    t.index ["employment_title"], name: "index_search_jobs_on_employment_title"
    t.index ["employment_type"], name: "index_search_jobs_on_employment_type"
    t.index ["industries"], name: "index_search_jobs_on_industries"
    t.index ["job_id"], name: "index_search_jobs_on_job_id", unique: true
    t.index ["location"], name: "index_search_jobs_on_location"
    t.index ["tags"], name: "index_search_jobs_on_tags"
  end

  create_table "search_saved_jobs", force: :cascade do |t|
    t.bigint "search_job_id", null: false
    t.string "user_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["search_job_id"], name: "index_search_saved_jobs_on_search_job_id"
    t.index ["user_id"], name: "index_search_saved_jobs_on_user_id"
  end

  create_table "seeker_references", id: :text, force: :cascade do |t|
    t.text "author_profile_id", null: false
    t.text "training_provider_id", null: false
    t.datetime "created_at", precision: 3, default: -> { "CURRENT_TIMESTAMP" }, null: false
    t.datetime "updated_at", precision: 3, null: false
    t.text "reference_text", null: false
    t.uuid "seeker_id", null: false
    t.index ["seeker_id"], name: "index_seeker_references_on_seeker_id"
  end

  create_table "seeker_training_providers", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.uuid "training_provider_id", null: false
    t.uuid "program_id"
    t.uuid "seeker_id", null: false
    t.string "status", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["program_id"], name: "index_seeker_training_providers_on_program_id"
    t.index ["seeker_id"], name: "index_seeker_training_providers_on_seeker_id"
    t.index ["training_provider_id"], name: "index_seeker_training_providers_on_training_provider_id"
  end

  create_table "seekers", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.string "bio"
    t.string "image"
    t.text "user_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.text "about"
    t.string "first_name"
    t.string "last_name"
    t.string "email"
    t.string "phone_number"
    t.string "zip_code"
    t.index ["user_id"], name: "index_seekers_on_user_id"
  end

  create_table "sessions", id: :text, force: :cascade do |t|
    t.text "session_token", null: false
    t.text "user_id", null: false
    t.datetime "expires", precision: 3, null: false
    t.datetime "created_at", precision: 3, default: -> { "CURRENT_TIMESTAMP" }, null: false
    t.datetime "updated_at", precision: 3, null: false
    t.index ["session_token"], name: "Session_session_token_key", unique: true
  end

  create_table "stories", id: :text, force: :cascade do |t|
    t.text "prompt", null: false
    t.text "response", null: false
    t.datetime "created_at", precision: 3, default: -> { "CURRENT_TIMESTAMP" }, null: false
    t.datetime "updated_at", precision: 3, null: false
    t.uuid "seeker_id", null: false
    t.index ["seeker_id"], name: "index_stories_on_seeker_id"
  end

  create_table "tags", id: :text, force: :cascade do |t|
    t.text "name", null: false
    t.datetime "created_at", precision: 3, default: -> { "CURRENT_TIMESTAMP" }, null: false
    t.datetime "updated_at", precision: 3, null: false
  end

  create_table "teams_teams", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.string "name", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "testimonials", id: :text, force: :cascade do |t|
    t.text "job_id", null: false
    t.text "name", null: false
    t.text "title", null: false
    t.text "testimonial", null: false
    t.text "photo_url"
    t.datetime "created_at", precision: 3, default: -> { "CURRENT_TIMESTAMP" }, null: false
    t.datetime "updated_at", precision: 3, null: false
  end

  create_table "training_provider_profiles", id: :text, force: :cascade do |t|
    t.text "training_provider_id", null: false
    t.text "user_id", null: false
    t.datetime "created_at", precision: 3, default: -> { "CURRENT_TIMESTAMP" }, null: false
    t.datetime "updated_at", precision: 3, null: false
    t.index ["user_id"], name: "TrainingProviderProfile_user_id_key", unique: true
  end

  create_table "training_providers", id: :text, force: :cascade do |t|
    t.text "name", null: false
    t.text "description", null: false
    t.datetime "created_at", precision: 3, default: -> { "CURRENT_TIMESTAMP" }, null: false
    t.datetime "updated_at", precision: 3, null: false
  end

  create_table "user_roles", force: :cascade do |t|
    t.text "user_id", null: false
    t.string "role", null: false
    t.index ["user_id"], name: "index_user_roles_on_user_id"
  end

  create_table "users", id: :text, force: :cascade do |t|
    t.text "email"
    t.datetime "email_verified", precision: 3
    t.text "image"
    t.text "first_name"
    t.text "last_name"
    t.text "zip_code"
    t.text "phone_number"
    t.datetime "created_at", precision: 3, default: -> { "CURRENT_TIMESTAMP" }, null: false
    t.datetime "updated_at", precision: 3, null: false
    t.string "sub", null: false
    t.uuid "person_id"
    t.index ["email"], name: "User_email_key", unique: true
    t.index ["sub"], name: "index_users_on_sub", unique: true
  end

  create_table "verification_tokens", id: false, force: :cascade do |t|
    t.text "identifier", null: false
    t.text "token", null: false
    t.datetime "expires", precision: 3, null: false
    t.datetime "created_at", precision: 3, default: -> { "CURRENT_TIMESTAMP" }, null: false
    t.datetime "updated_at", precision: 3, null: false
    t.index ["identifier", "token"], name: "VerificationToken_identifier_token_key", unique: true
    t.index ["token"], name: "VerificationToken_token_key", unique: true
  end

  create_table "webhooks", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.string "name", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  add_foreign_key "accounts", "users", name: "Account_user_id_fkey", on_update: :cascade, on_delete: :cascade
  add_foreign_key "analytics_dim_job_orders", "analytics_dim_jobs", column: "analytics_dim_jobs_id"
  add_foreign_key "analytics_dim_jobs", "analytics_dim_employers"
  add_foreign_key "analytics_dim_people", "analytics_dim_users"
  add_foreign_key "analytics_fact_applications", "analytics_dim_jobs"
  add_foreign_key "analytics_fact_applications", "analytics_dim_people"
  add_foreign_key "analytics_fact_candidates", "analytics_dim_job_orders", column: "analytics_dim_job_orders_id"
  add_foreign_key "analytics_fact_candidates", "analytics_dim_people", column: "analytics_dim_people_id"
  add_foreign_key "analytics_fact_coach_actions", "analytics_dim_people", column: "analytics_dim_person_target_id"
  add_foreign_key "analytics_fact_job_visibilities", "analytics_dim_jobs"
  add_foreign_key "analytics_fact_person_vieweds", "analytics_dim_people", column: "analytics_dim_person_viewed_id"
  add_foreign_key "applicant_statuses", "applicants", name: "ApplicantStatus_applicant_id_fkey", on_update: :cascade, on_delete: :restrict
  add_foreign_key "applicants", "seekers"
  add_foreign_key "career_paths", "jobs", name: "CareerPath_job_id_fkey", on_update: :cascade, on_delete: :restrict
  add_foreign_key "chats_messages", "chats_applicant_chats", column: "chats_applicant_chats_id"
  add_foreign_key "chats_read_receipts", "chats_applicant_chats", column: "chats_applicant_chats_id"
  add_foreign_key "credentials", "organizations", name: "Credential_organization_id_fkey", on_update: :cascade, on_delete: :nullify
  add_foreign_key "desired_certifications", "jobs", name: "DesiredCertification_job_id_fkey", on_update: :cascade, on_delete: :restrict
  add_foreign_key "desired_skills", "jobs", name: "DesiredSkill_job_id_fkey", on_update: :cascade, on_delete: :restrict
  add_foreign_key "education_experiences", "organizations", name: "EducationExperience_organization_id_fkey", on_update: :cascade, on_delete: :nullify
  add_foreign_key "education_experiences", "seekers"
  add_foreign_key "employers_applicants", "employers_jobs"
  add_foreign_key "employers_job_owners", "employers_jobs"
  add_foreign_key "employers_job_owners", "employers_recruiters"
  add_foreign_key "employers_jobs", "employers_employers"
  add_foreign_key "employers_recruiters", "employers_employers"
  add_foreign_key "job_attributes", "jobs"
  add_foreign_key "job_orders_candidates", "job_orders_job_orders", column: "job_orders_job_orders_id"
  add_foreign_key "job_orders_candidates", "job_orders_people", column: "job_orders_people_id"
  add_foreign_key "job_orders_job_orders", "job_orders_jobs", column: "job_orders_jobs_id"
  add_foreign_key "job_photos", "jobs", name: "JobPhoto_job_id_fkey", on_update: :cascade, on_delete: :restrict
  add_foreign_key "job_tags", "jobs", name: "JobTag_job_id_fkey", on_update: :cascade, on_delete: :restrict
  add_foreign_key "job_tags", "tags", name: "JobTag_tag_id_fkey", on_update: :cascade, on_delete: :restrict
  add_foreign_key "jobs", "employers", name: "Job_employer_id_fkey", on_update: :cascade, on_delete: :restrict
  add_foreign_key "learned_skills", "jobs", name: "LearnedSkill_job_id_fkey", on_update: :cascade, on_delete: :restrict
  add_foreign_key "other_experiences", "organizations", name: "OtherExperience_organization_id_fkey", on_update: :cascade, on_delete: :nullify
  add_foreign_key "other_experiences", "seekers"
  add_foreign_key "people_search_person_education_experiences", "people_search_people", column: "person_id", on_delete: :cascade
  add_foreign_key "people_search_person_experiences", "people_search_people", column: "person_id", on_delete: :cascade
  add_foreign_key "personal_experiences", "seekers"
  add_foreign_key "profile_skills", "seekers"
  add_foreign_key "profiles", "users", name: "Profile_user_id_fkey", on_update: :cascade, on_delete: :restrict
  add_foreign_key "programs", "training_providers", name: "Program_training_provider_id_fkey", on_update: :cascade, on_delete: :restrict
  add_foreign_key "recruiters", "users", name: "Recruiter_user_id_fkey", on_update: :cascade, on_delete: :restrict
  add_foreign_key "screeners_answers", "screeners_questions", column: "screeners_questions_id"
  add_foreign_key "search_applications", "search_jobs"
  add_foreign_key "search_saved_jobs", "search_jobs"
  add_foreign_key "seeker_references", "training_providers", name: "Reference_training_provider_id_fkey", on_update: :cascade, on_delete: :restrict
  add_foreign_key "sessions", "users", name: "Session_user_id_fkey", on_update: :cascade, on_delete: :cascade
  add_foreign_key "stories", "seekers"
  add_foreign_key "testimonials", "jobs", name: "Testimonial_job_id_fkey", on_update: :cascade, on_delete: :restrict
  add_foreign_key "training_provider_profiles", "users", name: "TrainingProviderProfile_user_id_fkey", on_update: :cascade, on_delete: :restrict
  add_foreign_key "user_roles", "users"
end

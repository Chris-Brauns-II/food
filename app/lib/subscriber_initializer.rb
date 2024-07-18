module SubscriberInitializer
  def self.run
    ASYNC_SUBSCRIBERS.reset
    SYNC_SUBSCRIBERS.reset

    aggregators = [
      DbStreamListener.build(consumer: JobOrders::JobOrdersAggregator.new, listener_name: "job_orders_aggregator"),
      DbStreamListener.build(consumer: Analytics::AnalyticsAggregator.new, listener_name: "analytics"),
      DbStreamListener.build(consumer: Attributes::AttributesAggregator.new, listener_name: "attributes_aggregator"),
      DbStreamListener.build(consumer: Coaches::CoachesAggregator.new, listener_name: "coach_seekers"),
      DbStreamListener.build(consumer: Jobs::JobsAggregator.new, listener_name: "jobs_aggregator"),
      DbStreamListener.build(consumer: JobSearch::JobSearchAggregator.new, listener_name: "search"),
      DbStreamListener.build(consumer: People::PersonAggregator.new, listener_name: "person_aggregator"),
      DbStreamListener.build(consumer: Invites::InvitesAggregator.new, listener_name: "invites_aggregator"),
      DbStreamListener.build(consumer: Chats::ChatsAggregator.new, listener_name: "chats_aggregator"),
      DbStreamListener.build(consumer: Contact::ContactAggregator.new, listener_name: "contact_aggregator"),
      DbStreamListener.build(consumer: Users::UsersAggregator.new, listener_name: "users_aggregator"),
      DbStreamListener.build(consumer: Infrastructure::InfrastructureAggregator.new, listener_name: "infrastructure_aggregator"),
      DbStreamListener.build(consumer: Employers::EmployerAggregator.new, listener_name: "employers"),
      DbStreamListener.build(consumer: TrainingProviders::TrainingProviderAggregator.new, listener_name: "training_provider_aggregator"),
      DbStreamListener.build(consumer: Qualifications::QualificationsAggregator.new, listener_name: "qualifications_aggregator"),
      DbStreamListener.build(consumer: Documents::DocumentsAggregator.new, listener_name: "documents_aggregator"),
      DbStreamListener.build(consumer: PeopleSearch::PeopleAggregator.new, listener_name: "people_search_people_aggregator"),
      DbStreamListener.build(consumer: Teams::TeamsAggregator.new, listener_name: "teams_aggregator"),
      DbStreamListener.build(consumer: Screeners::ScreenerAggregator.new, listener_name: "screener_aggregator")
    ]

    reactors = [
      DbStreamListener.build(consumer: Coaches::CoachesReactor.new, listener_name: "coach_seekers_reactor"),
      DbStreamListener.build(consumer: Klaviyo::KlaviyoReactor.new, listener_name: "klayvio_reactor"),
      DbStreamListener.build(consumer: Applicants::OrchestrationReactor.new, listener_name: "applicants_orchestration_reactor"),
      DbStreamListener.build(consumer: Attributes::AttributesReactor.new, listener_name: "attributes_reactor"),
      DbStreamListener.build(consumer: Jobs::JobsReactor.new, listener_name: "jobs_reactor"),
      DbStreamListener.build(consumer: Invites::InvitesReactor.new, listener_name: "invites_reactor"),
      DbStreamListener.build(consumer: Slack::SlackReactor.new, listener_name: "slack_reactor"),
      DbStreamListener.build(consumer: Contact::ContactReactor.new, listener_name: "contact_reactor"),
      DbStreamListener.build(consumer: People::OnboardingReactor.new, listener_name: "onboarding_reactor"),
      DbStreamListener.build(consumer: People::PersonDedupingReactor.new, listener_name: "person_deduping_reactor"),
      DbStreamListener.build(consumer: JobOrders::JobOrdersReactor.new, listener_name: "job_orders_reactor"),
      DbStreamListener.build(consumer: JobOrders::TeamOrderStatusReactor.new, listener_name: "team_order_status_reactor"),
      DbStreamListener.build(consumer: Infrastructure::InfrastructureReactor.new, listener_name: "infrastructure_reactor"),
      DbStreamListener.build(consumer: Contact::SmsReactor.new, listener_name: "contact_sms"),
      DbStreamListener.build(consumer: Users::UsersReactor.new, listener_name: "users_reactor"),
      DbStreamListener.build(consumer: Contact::SmtpReactor.new, listener_name: "contact_smtp"),
      DbStreamListener.build(consumer: Contact::CalDotCom::SchedulingReactor.new, listener_name: "cal_com_scheduling"),
      DbStreamListener.build(consumer: Employers::EmployerReactor.new, listener_name: "employers_application_notification_service"),
      DbStreamListener.build(consumer: TrainingProviders::TrainingProviderReactor.new, listener_name: "training_provider_reactor"),
      DbStreamListener.build(consumer: Documents::DocumentsReactor.new, listener_name: "documents_reactor"),
      DbStreamListener.build(consumer: Teams::TeamsReactor.new, listener_name: "teams_reactor"),
      DbStreamListener.build(consumer: Screeners::ScreenerReactor.new, listener_name: "screener_reactor")
    ]

    (aggregators + reactors).each do |listener|
      listener.handled_messages_sync.each do |schema|
        SYNC_SUBSCRIBERS.subscribe(
          schema:,
          subscriber: listener
        )
      end

      listener.handled_messages.each do |schema|
        ASYNC_SUBSCRIBERS.subscribe(
          schema:,
          subscriber: listener
        )
      end
    end
  end
end

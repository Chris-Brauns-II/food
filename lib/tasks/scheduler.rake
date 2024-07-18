task elapse_day: :environment do
  ElapseDayJob.perform_later
end

task update_streams: :environment do
  play_stream_jobs = StreamListener.all_listener.map do |listener_name|
    PlayStreamJob.new(listener_name:)
  end

  ActiveJob.perform_all_later(play_stream_jobs)
end

task execute_scheduled_tasks: :environment do
  ExecuteTasksJob.perform_later
end

task cleanup_destroyed_messages: :environment do
  CleanupDestroyedMessagesJob.perform_later
end

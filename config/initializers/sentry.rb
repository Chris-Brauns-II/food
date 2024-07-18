Sentry.init do |config|
  config.enabled_environments = %w[production staging]
  config.dsn = 'https://5171b69239b54a152ba7c863f4da3279@o4505908771094528.ingest.sentry.io/4505908771094528'
  config.breadcrumbs_logger = %i[active_support_logger http_logger]

  # To activate performance monitoring, set one of these options.
  # We recommend adjusting the value in production:
  config.traces_sample_rate = 1.0
end

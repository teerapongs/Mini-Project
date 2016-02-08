ActionMailer::Base.smtp_settings[:address]        = ENV['MAILER_ADDRESS'] || 'localhost'
ActionMailer::Base.smtp_settings[:port]           = ENV['MAILER_PORT'] || 1025
ActionMailer::Base.smtp_settings[:authentication] = ENV['MAILER_AUTHENTICATION']
ActionMailer::Base.smtp_settings[:user_name]      = ENV['MAILER_USERNAME']
ActionMailer::Base.smtp_settings[:password]       = ENV['MAILER_PASSWORD']
ActionMailer::Base.smtp_settings[:domain]         = ENV['MAILER_DOMAIN']


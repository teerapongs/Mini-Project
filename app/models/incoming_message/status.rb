require_relative 'simple'

class IncomingMessage
  class Status < Simple

    def execute
      super

      message = channel.today_standups.map do |standup|
        "#{standup.status}\n"
      end

      channel.message(message.join)
    end

  end
end


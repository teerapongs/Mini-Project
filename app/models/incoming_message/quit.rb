require_relative 'simple'

class IncomingMessage
  class Quit < Simple

    def execute
      super

      channel.message(I18n.t('incoming_message.quit'))
    end

  end
end


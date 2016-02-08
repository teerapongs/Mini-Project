require_relative 'base'

class IncomingMessage
  class Simple < Base

    DESCRIPTION_REGEXP = %r{^-([a-zA-Z]|\/)+\s(.+)$}

    # @override
    def description
      @message['text'][DESCRIPTION_REGEXP, 2].try(:strip)
    end

  end
end

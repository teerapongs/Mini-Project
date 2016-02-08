class IncomingMessage
  class Base

    class InvalidCommandError < StandardError; end

    # @param [Hash] message The message we got from slack channel.
    # @option message [String] :type.
    # @option message [String] :channel.
    # @option message [String] :user.
    # @option message [String] :text.
    # @param [Standup] standup The current standup.
    def initialize(message, standup)
      @message = message
      @standup = standup
    end

    # Executes given command if suffice all the validations.
    def execute
      self.validate!
    end

    # @return [Boolean]
    # @raise [InvalidCommandError]
    def validate!
      true
    end

    # @return [Channel]
    def channel
      @standup.channel
    end

    # Returns the user that created the message.
    #
    # @return [User]
    def user
      User.where(slack_id: @message['user']).first
    end

    # Returns the description that was given with the command.
    #
    # For example
    #
    #   santiagodoldan> -n/a: @another.user Doctor appt.
    #
    # @return [String]
    def description
      raise 'Missing implementation IncomingMessage::Base.description'
    end

  end
end

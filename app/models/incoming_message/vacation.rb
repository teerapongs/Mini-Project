require_relative 'compound'

class IncomingMessage
  class Vacation < Compound

    def execute
      super

      @standup.vacation!

      channel.message("<@#{reffered_user.slack_id}> has been put on vacation.")
    end

    def validate!
      if !user.admin?
        raise InvalidCommandError.new("You don't have permission to vacation a user.")
      elsif @standup.idle?
        raise InvalidCommandError.new("You need to wait until <@#{reffered_user.slack_id}> turns.")
      elsif @standup.completed?
        raise InvalidCommandError.new("<@#{reffered_user.slack_id}> has already completed standup today.")
      elsif @standup.answering?
        raise InvalidCommandError.new("<@#{reffered_user.slack_id}> is doing his/her standup.")
      end

      super
    end

  end
end


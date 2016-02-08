class IncomingMessage
  class AutoSkip
    MAX_ATTEMPTS = 1

    # @param [Integer] standup_id The id of the standup that will be auto skipped.
    # @param [Date] standup_updated_at The last time the standup was updated.
    def initialize(standup_id, standup_updated_at)
      @standup_id         = standup_id
      @standup_updated_at = standup_updated_at
    end

    # If the users wasn't skipped yet, we automatically skip the user to have a more dinamic standup.
    def perform
      return unless needs_to_be_skipped?

      # TODO This logic is already in the app/models/incoming_message/skip.rb class,
      #   we need first to move all the slack client logic to a separate class and then reuse that logic.
      change_state_of_current_standup

      if standup.not_available?
        standup.channel.message(I18n.t('incoming_message.not_available', user: standup.user_slack_id))
      elsif next_standup && standup.id != next_standup.id
        standup.channel.message(I18n.t('incoming_message.skip', user: standup.user_slack_id))
      end

      if next_standup.present?
        next_standup.init!

        skip_next_standup

        if standup.id != next_standup.id
          standup.channel.message(I18n.t('incoming_message.welcome', user: next_standup.user_slack_id))
        end
      end

      if standup.channel.complete?
        url = Rails.application.routes.url_helpers.channel_standups_url(channel_id: standup.channel.id,
                                                                        host: Setting.first.web_url)

        standup.channel.message(I18n.t('incoming_message.resume', url: url))
      end
    end
    handle_asynchronously :perform, run_at: Proc.new { (Setting.first.auto_skip_timeout).minutes.from_now }

    # @override
    #
    # If the job failed it won't be executed again.
    def max_attempts
      MAX_ATTEMPTS
    end

    private

    # Increments the auto_skipped_times flag by 1, then depending on the number of auto_skipped_times
    #   it skips the standup or set the user not available.
    def change_state_of_current_standup
      standup.increment!(:auto_skipped_times)

      if standup.auto_skipped_times >= Standup::MAXIMUM_AUTO_SKIPPED_TIMES
        standup.not_available!
      else
        standup.skip!
      end
    end

    # Creates a new job to auto skip the next standup.
    def skip_next_standup
      AutoSkip.new(next_standup.id, next_standup.updated_at).perform
    end

    # Returns true only when given standup needs to be skipped automatically for us, otherwise returns false.
    #
    # @return [Boolean]
    def needs_to_be_skipped?
      standup.present? && standup.channel.active?
    end

    # @return [Standup]
    def standup
      @standup ||= Standup.active.where(id: @standup_id, updated_at: @standup_updated_at).first
    end

    # @return [Standup]
    def next_standup
      @next_standup ||= standup.channel.pending_standups.first
    end

  end
end

module Standupbot
  class Sync

    # @param [String] channel_id.
    def initialize(channel_id)
      @channel_id = channel_id
      @settings   = Setting.first
      @client     = ::Slack::Web::Client.new(token: @settings.api_token)
    end

    # @return [Boolean]
    def valid?
      @client.auth_test

      slack_channel.present? && bot_id.present?

    rescue ::Slack::Web::Api::Error
      false
    end

    # @retun [Array] contains all the error messages.
    def errors
      [].tap do |result|
        begin
          @client.auth_test

          result << "We didn't find the channel you entered, please double check that the name is correct" if slack_channel.empty?
          result << "There is no Bot called @#{@settings.bot_name} within given Channel" if bot_id.nil?
        rescue ::Slack::Web::Api::Error
          result << "The Bot API Token is invalid"
        end
      end
    end

    # It creates all the necessary data to start the standup.
    #
    def create!
      channel = Channel.where(name: slack_channel['name'], slack_id: slack_channel['id']).first_or_initialize

      ActiveRecord::Base.transaction do
        channel.save!

        @settings.update_attributes(bot_id: bot_id)

        channel.users = []

        slack_channel['members'].each do |member|
          channel.users << User.create_with_slack_data(user_by_slack_id(member))
        end
      end

      channel
    end

    private

    # @return [Hash] The channel data we get from slack.
    def slack_channel
      @slack_channel ||= Slack::Channel.by_id(@channel_id) || {}
    end

    # Returns a user for given slack id.
    #
    # @param [String] slack_id.
    # @return [Hash]
    def user_by_slack_id(slack_id)
      users.find { |u| u['id'] == slack_id }
    end

    # Returns the bot id.
    #
    # @return [String]
    def bot_id
      users.find { |what| what['name'] == @settings.bot_name }.try(:[], 'id')
    end

    # Returns a list of all the users within the slack team.
    #
    # @return [Hash]
    def users
      @client.users_list['members']
    end

  end
end

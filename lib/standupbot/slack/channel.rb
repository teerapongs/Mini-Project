require_relative '../slack'

module Standupbot
  module Slack
    class Channel

      class << self

        # Returns the data from the slack api.
        #
        # @param [String] id The slack channel id.
        # @return [Hash]
        def by_id(id)
          self.all.find { |channel| channel['id'] == id }
        end

        # Returns the data from the slack api.
        #
        # @param [String] name The slack channel name.
        # @return [Hash]
        def by_name(name)
          self.all.find { |channel| channel['name'] == name }
        end

        # Returns all the channels from current slack team, includes both public and private channels.
        #
        # @return [Hash] The private and public channels.
        def all
          private_channels = Standupbot::Slack.client.groups_list['groups'] || []
          public_channels  = Standupbot::Slack.client.channels_list['channels'] || []

          private_channels | public_channels
        end

      end

    end
  end
end

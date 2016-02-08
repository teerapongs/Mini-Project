module Standupbot
  module Slack
    class Client

      # @param [Channel] channel.
      def initialize(channel)
        @channel = channel
        @client  = ::Slack::Web::Client.new(token: Setting.first.api_token)
      end

      # Sends given message to the slack current channel.
      #
      # @param [String] text.
      def message(text)
        @client.chat_postMessage(channel: @channel.slack_id, text: text, as_user: true)
      end

      # Checks that given api token is correct.
      #
      # @return [Boolean]
      def auth_test
        @client.auth_test
      end

    end
  end
end

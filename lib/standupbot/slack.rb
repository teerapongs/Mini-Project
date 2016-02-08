module Standupbot
  module Slack

    # @return [Slack::Web::Client]
    def self.client
      @client ||= ::Slack::Web::Client.new(token: Setting.first.try(:api_token))
    end

  end
end

require 'rails_helper'

describe StandupMailer do

  describe '.today_report' do
    let(:channel) { create(:channel) }
    let(:standup) { create(:standup, channel: channel,
                                     today: Faker::Lorem.sentence,
                                     yesterday: Faker::Lorem.sentence,
                                     conflicts: Faker::Lorem.sentence) }

    before { channel.users << standup.user }

    it 'uses the correct subject text' do
      expect(described_class.today_report(channel.id).subject).to eq("Standup of #{Time.zone.now.strftime('%A, %d %B, %Y')}")
    end

    it 'uses the correct from email' do
      expect(described_class.today_report(channel.id).from).to eq(['standupbot@sofetch.io'])
    end

    context 'when there are no users to send the report' do
      before do
        standup.user.update_column(:send_standup_report, false)
      end

      it 'does not send any email' do
        expect_any_instance_of(described_class).to_not receive(:mail)

        described_class.today_report(channel.id).subject
      end
    end

    context 'body' do
      let(:body) { described_class.today_report(channel.id).body.raw_source }

      it 'includes the today answer' do
        expect(body).to include(standup.today)
      end

      it 'includes the yesterday answer' do
        expect(body).to include(standup.yesterday)
      end

      it 'includes the conflicts answer' do
        expect(body).to include(standup.conflicts)
      end
    end
  end

end

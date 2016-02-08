require 'rails_helper'

describe User do

  describe '.non_bot' do
    let(:bot)   { create(:user, :bot) }
    let(:admin) { create(:user, :admin) }
    let(:user)  { create(:user) }

    it 'does not include bot users' do
      expect(described_class.non_bot).to_not include(bot)
    end

    it 'includes admin users' do
      expect(described_class.non_bot).to include(admin)
    end

    it 'includes default users' do
      expect(described_class.non_bot).to include(user)
    end
  end

  describe '.send_report' do
    let(:user_1) { create(:user, send_standup_report: true) }
    let(:user_2) { create(:user, send_standup_report: false) }

    it 'returns only users with the flag as true' do
      expect(described_class.send_report).to match_array([user_1])
    end
  end

end

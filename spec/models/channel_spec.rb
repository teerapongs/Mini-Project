require 'rails_helper'

describe Channel do

  subject { build(:channel) }

  describe '#available_users' do
    before { subject.save }

    it 'does not include bots' do
      bot = create(:user, :bot)

      subject.users << bot

      expect(subject.available_users).to_not include(bot)
    end

    it 'does not include disabled users' do
      user = create(:user, :disabled)

      subject.users << user

      expect(subject.available_users).to_not include(user)
    end

    it 'includes enabled users' do
      user = create(:user, :enabled)

      subject.users << user

      expect(subject.available_users).to include(user)
    end
  end

end

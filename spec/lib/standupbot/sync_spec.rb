require 'rails_helper'

describe Standupbot::Sync do

  let!(:settings)   { create(:setting) }
  let!(:web_client) { SlackMock.web_client }

  let(:channel_id) { Faker::Number.number(10) }

  let(:member) do
    { 'id' => Faker::Number.number(10),
      'name' => Faker::Name.name,
      'is_bot' => false,
      'profile' => { 'real_name_normalized' => Faker::Name.name,
                     'email' => Faker::Internet.email,
                     'image_72' => Faker::Avatar.image } }
  end

  let(:members) { [member['id']] }

  let(:slack_channel) do
    { 'name' => Faker::Name.name, 'id' => Faker::Number.number(10), 'members' => members }
  end

  subject { described_class.new(channel_id) }

  before do
    allow(subject).to receive(:slack_channel).and_return(slack_channel)

    allow(web_client).to receive(:users_list).and_return({ 'members' => [member] })
  end

  describe '#valid?' do
    context 'when auth_client raises an error' do
      before { allow(web_client).to receive(:auth_test).and_raise(Slack::Web::Api::Error.new(nil, nil)) }

      it 'returns false' do
        expect(subject.valid?).to be_falsey
      end
    end

    context 'when auth_client does not raise an error' do
      before { allow(web_client).to receive(:auth_test).and_return(true) }

      it 'returns false' do
        expect(subject.valid?).to be_falsey
      end

      context 'and the slack channel exists' do
        it 'returns false' do
          expect(subject.valid?).to be_falsey
        end

        context 'and the bot was invited to the channel' do
          let(:members) { [member['id'], bot['id']] }
          let(:bot)     { { 'id' => Faker::Number.number(10), 'name' => settings.bot_name } }

          before do
            allow(web_client).to receive(:users_list).and_return({ 'members' => [member, bot] })
          end

          it 'returns true' do
            expect(subject.valid?).to be_truthy
          end
        end
      end
    end
  end

  describe '#errors' do
    context 'when auth_client raises an error' do
      before { allow(web_client).to receive(:auth_test).and_raise(Slack::Web::Api::Error.new(nil, nil)) }

      it 'returns the correct message' do
        expect(subject.errors).to eq(['The Bot API Token is invalid'])
      end
    end

    context 'when auth_client does not raise an error' do
      before { allow(web_client).to receive(:auth_test).and_return(true) }

      context 'and the slack channel does not exist' do
        before { allow(subject).to receive(:slack_channel).and_return({}) }

        it 'returns the correct message' do
          expect(subject.errors).to eq(["We didn't find the channel you entered, please double check that the name is correct",
                                        "There is no Bot called @#{settings.bot_name} within given Channel"])
        end
      end

      context 'and the slack channel exists' do
        it 'returns the correct message' do
          expect(subject.errors).to eq(["There is no Bot called @#{settings.bot_name} within given Channel"])
        end

        context 'and the bot was invited to the channel' do
          let(:members) { [member['id'], bot['id']] }
          let(:bot)     { { 'id' => Faker::Number.number(10), 'name' => settings.bot_name } }

          before do
            allow(web_client).to receive(:users_list).and_return({ 'members' => [member, bot] })
          end

          it 'returns the correct message' do
            expect(subject.errors).to be_empty
          end
        end
      end
    end
  end

  describe '#create!' do
    it 'creates a new channel' do
      expect { subject.create! }.to change(Channel, :count).by(1)
    end

    it 'assigns correctly the channel name' do
      channel = subject.create!

      expect(channel.name).to eq(slack_channel['name'])
    end

    it 'assigns correctly the channel slack id' do
      channel = subject.create!

      expect(channel.slack_id).to eq(slack_channel['id'])
    end

    it 'associates correctly the users to the channel' do
      channel = subject.create!
      user    = channel.users.first

      expect(user.slack_id).to eq(member['id'])
    end

    context 'when the channel already exists' do
      let!(:channel) { create(:channel, slack_id: slack_channel['id'], name: slack_channel['name']) }

      it 'does not create a new channel' do
        expect { subject.create! }.to_not change(Channel, :count)
      end

      it 'returns the channel' do
        expect(subject.create!).to eq(channel)
      end
    end
  end

end

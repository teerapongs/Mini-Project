require 'rails_helper'

describe IncomingMessage::Simple do

  let(:text)    { "-n/a" }
  let(:message) { { 'text' => text } }
  let(:standup) { create(:standup, :active) }

  subject { described_class.new(message, standup) }

  describe '#description' do
    context 'when given a description' do
      let(:description) { Faker::Lorem.sentence }
      let(:text)        { "-n/a #{description}" }

      it 'returns only the description' do
        expect(subject.description).to eq(description)
      end

      context 'and it includes weird characters' do
        let(:description) { 'Description~!@#$%^&*()_+.?<\| finish.' }

        it 'returns only the description' do
          expect(subject.description).to eq(description)
        end
      end
    end

    context 'when the description has several white spaces after the command' do
      let(:description) { Faker::Lorem.sentence }
      let(:text)        { "-n/a  #{description}" }

      it 'returns the description anyway' do
        expect(subject.description).to eq(description)
      end
    end

    context 'when given no description' do
      it 'returns nil' do
        expect(subject.description).to be_nil
      end
    end
  end

end


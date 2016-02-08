require 'rails_helper'

describe ApplicationHelper do

  describe '.emojify' do
    let!(:setting) { create(:setting) }

    let(:text_with_emoji_texts)           { 'Testing emoji :scream:' }
    let(:text_with_multiple_emoji_texts)  { 'Testing emoji :scream: and :mask:' }
    let(:text_with_incorrect_emoji_texts) { 'Testing emoji :screams:' }

    it 'changes emoji texts for emoji images' do
      emoji = Emoji.find_by_alias('scream')

      expect(helper.emojify(text_with_emoji_texts)).to include("emoji/#{emoji.image_filename}")
    end

    it 'changes multiple emoji texts for its corresponding emoji image' do
      emoji_1 = Emoji.find_by_alias('scream')
      emoji_2 = Emoji.find_by_alias('mask')

      expect(helper.emojify(text_with_multiple_emoji_texts)).to include("emoji/#{emoji_1.image_filename}")
      expect(helper.emojify(text_with_multiple_emoji_texts)).to include("emoji/#{emoji_2.image_filename}")
    end

    it 'does not change invalid emoji texts for emoji images' do
      emoji = Emoji.find_by_alias('scream')

      expect(helper.emojify(text_with_incorrect_emoji_texts)).to_not include("emoji/#{emoji.image_filename}")
    end
  end

end

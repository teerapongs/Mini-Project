module ApplicationHelper

  # Transoforms emoji texts to emoji images.
  #
  # @param [String] content The text that contains the emoji emoticons
  def emojify(content)
    return if content.blank?

    result = h(content).to_str.gsub(/:([\w+-]+):/) do |match|
      if emoji = Emoji.find_by_alias($1)
        %{<img alt="#$1" \
               src="#{image_url("emoji/#{emoji.image_filename}", host: Setting.first.web_url)}" \
               style="vertical-align:middle" \
               width="20" \
               height="20"/>}
      else
        match
      end
    end

    result.html_safe
  end

end

# == Schema Information
#
# Table name: settings
#
#  id                :integer          not null, primary key
#  name              :string
#  bot_id            :string
#  bot_name          :string
#  web_url           :string
#  api_token         :string
#  auto_skip_timeout :integer          default(2)
#

class Setting < ActiveRecord::Base

  validates :auto_skip_timeout, presence: true

end

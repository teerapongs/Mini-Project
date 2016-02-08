# == Schema Information
#
# Table name: channel_users
#
#  id         :integer          not null, primary key
#  user_id    :integer
#  channel_id :integer
#

class ChannelUser < ActiveRecord::Base

  belongs_to :channel
  belongs_to :user

end

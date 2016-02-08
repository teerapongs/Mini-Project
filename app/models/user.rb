# == Schema Information
#
# Table name: users
#
#  id                  :integer          not null, primary key
#  slack_id            :string
#  full_name           :string
#  admin               :boolean          default(TRUE)
#  nickname            :string
#  avatar_url          :string
#  bot                 :boolean          default(FALSE)
#  email               :string
#  send_standup_report :boolean          default(TRUE)
#  disabled            :boolean          default(FALSE)
#

class User < ActiveRecord::Base

  has_many :standups
  has_many :channel_users
  has_many :channels, through: :channel_users

  validates :slack_id, uniqueness: true

  scope :non_bot, -> { where(bot: false) }
  scope :enabled, -> { where(disabled: false) }
  scope :admin, -> { where(admin: true) }
  scope :send_report, -> { where(send_standup_report: true) }

  class << self

    def registered?(id)
      User.where(slack_id: id).exists?
    end

    # Creates a user using given data from Slack.
    #
    # @param [Hash] data The data from the Slack API.
    # @return [User]
    def create_with_slack_data(data)
      user = User.where(slack_id: data['id']).first_or_initialize

      user.full_name= data['profile']['real_name_normalized']
      user.email= data['profile']['email']
      user.nickname= data['name']
      user.avatar_url= data['profile']['image_72']
      user.bot= data['is_bot']

      user.save!

      user
    end

  end

end

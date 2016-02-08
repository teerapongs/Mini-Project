class AssociateUsersAndChannelsAndRemoveChannelIdColumn < ActiveRecord::Migration
  def change
    User.all.each do |user|
      channel = Channel.find(user.channel_id)

      channel.users << user
    end

    remove_column :users, :channel_id
  end
end

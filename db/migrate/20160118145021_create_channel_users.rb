class CreateChannelUsers < ActiveRecord::Migration
  def change
    create_table :channel_users do |t|
      t.references :user
      t.references :channel
    end
  end
end

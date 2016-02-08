class AddChannelIdToStandups < ActiveRecord::Migration
  def change
    add_column :standups, :channel_id, :integer
  end
end

class RemoveChannelTypeFromSettings < ActiveRecord::Migration
  def change
    remove_column :settings, :channel_type, :string, default: 'group'
  end
end

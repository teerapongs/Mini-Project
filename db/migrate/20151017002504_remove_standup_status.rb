class RemoveStandupStatus < ActiveRecord::Migration
  def change
    remove_column :users, :standup_status
  end
end

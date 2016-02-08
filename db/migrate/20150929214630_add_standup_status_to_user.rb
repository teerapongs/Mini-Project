class AddStandupStatusToUser < ActiveRecord::Migration
  def change
    add_column :users, :standup_status, :string, default: "not_ready"
  end
end

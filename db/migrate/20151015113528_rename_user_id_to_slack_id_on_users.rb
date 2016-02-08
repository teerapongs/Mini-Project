class RenameUserIdToSlackIdOnUsers < ActiveRecord::Migration
  def change
    rename_column :users, :user_id, :slack_id
  end
end

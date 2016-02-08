class RenameAdminUserToAdmin < ActiveRecord::Migration
  def change
    rename_column :users, :admin_user, :admin
  end
end

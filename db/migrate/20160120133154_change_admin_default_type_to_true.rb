class ChangeAdminDefaultTypeToTrue < ActiveRecord::Migration
  def change
    change_column_default :users, :admin, true

    User.update_all(admin: true)
  end
end

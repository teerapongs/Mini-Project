class ChangeUserIdTypeOnStandups < ActiveRecord::Migration
  def change
    remove_column :standups, :user_id
    add_column :standups, :user_id, :integer
  end
end

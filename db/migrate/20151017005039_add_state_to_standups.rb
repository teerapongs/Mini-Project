class AddStateToStandups < ActiveRecord::Migration
  def change
    remove_column :standups, :editing
    remove_column :standups, :status
    add_column :standups, :state, :string
  end
end

class AddEditing < ActiveRecord::Migration
  def change
    add_column :standups, :editing, :boolean, default: false
  end
end

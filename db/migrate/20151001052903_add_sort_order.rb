class AddSortOrder < ActiveRecord::Migration
  def change
    add_column :users, :sort_order, :int, default: 1
  end
end

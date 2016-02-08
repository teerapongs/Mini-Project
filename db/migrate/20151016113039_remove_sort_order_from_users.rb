class RemoveSortOrderFromUsers < ActiveRecord::Migration
  def change
    remove_column :users, :sort_order
  end
end

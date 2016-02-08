class AddOrderToStandups < ActiveRecord::Migration
  def change
    add_column :standups, :order, :integer, default: 1
  end
end

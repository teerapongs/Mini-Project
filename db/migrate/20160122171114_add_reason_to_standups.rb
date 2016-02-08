class AddReasonToStandups < ActiveRecord::Migration
  def change
    add_column :standups, :reason, :string
  end
end

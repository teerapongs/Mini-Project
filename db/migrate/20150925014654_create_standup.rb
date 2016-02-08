class CreateStandup < ActiveRecord::Migration
  def change
    create_table :standups do |t|
      t.column :user_id, :string
      t.column :yesterday, :text
      t.column :today, :text
      t.column :conflicts, :text
      t.column :status, :string, default: "disabled"
      t.timestamps
    end
  end
end

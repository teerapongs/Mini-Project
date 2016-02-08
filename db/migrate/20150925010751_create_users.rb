class CreateUsers < ActiveRecord::Migration
  def change
    create_table :users do |t|
      t.column :user_id, :string
    end
  end
end

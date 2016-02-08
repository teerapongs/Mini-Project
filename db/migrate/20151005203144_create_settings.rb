class CreateSettings < ActiveRecord::Migration
  def change
    create_table :settings do |t|
      t.column :channel_type, :string, default: "group"
      t.column :name, :string, default: "Standup"
      t.column :bot_id, :string
    end
  end
end

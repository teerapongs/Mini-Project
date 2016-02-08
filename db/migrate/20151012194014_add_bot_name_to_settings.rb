class AddBotNameToSettings < ActiveRecord::Migration
  def change
    add_column :settings, :bot_name, :string
  end
end

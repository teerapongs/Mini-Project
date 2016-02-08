class AddApiTokenToSettings < ActiveRecord::Migration
  def change
    add_column :settings, :api_token, :string
  end
end

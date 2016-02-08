class MoveAvatarUrlToUsers < ActiveRecord::Migration
  def change
    remove_column :standups, :avatar_url
    add_column :users, :avatar_url, :string
  end
end

class AddAvatarUrl < ActiveRecord::Migration
  def change
    add_column :standups, :avatar_url, :string
  end
end

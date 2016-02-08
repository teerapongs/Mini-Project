class AddLinkToSettings < ActiveRecord::Migration
  def change
    add_column :settings, :web_url, :string
  end
end

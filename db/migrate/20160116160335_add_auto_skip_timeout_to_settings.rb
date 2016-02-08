class AddAutoSkipTimeoutToSettings < ActiveRecord::Migration
  def change
    add_column :settings, :auto_skip_timeout, :integer, default: 2
  end
end

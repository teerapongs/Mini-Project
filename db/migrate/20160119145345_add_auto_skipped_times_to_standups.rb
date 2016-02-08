class AddAutoSkippedTimesToStandups < ActiveRecord::Migration
  def change
    add_column :standups, :auto_skipped_times, :integer, default: 0
  end
end

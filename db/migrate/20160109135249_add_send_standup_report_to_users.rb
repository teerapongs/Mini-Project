class AddSendStandupReportToUsers < ActiveRecord::Migration
  def change
    add_column :users, :send_standup_report, :boolean, default: true
  end
end

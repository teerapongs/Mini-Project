class PopulateApiTokenIfEnvVariableExists < ActiveRecord::Migration
  def up
    if Setting.first.present? && ENV['SLACK_API_TOKEN'].present?
      Setting.first.update_column(:api_token, ENV['SLACK_API_TOKEN'])
    end
  end

  def down
  end
end

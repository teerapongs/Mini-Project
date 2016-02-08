class RemoveDefaultValueOfChannelName < ActiveRecord::Migration
  def change
    execute 'alter table settings alter name drop default'
  end
end

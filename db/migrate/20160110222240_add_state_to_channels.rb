class AddStateToChannels < ActiveRecord::Migration
  def change
    add_column :channels, :state, :string, default: 'idle'
  end
end

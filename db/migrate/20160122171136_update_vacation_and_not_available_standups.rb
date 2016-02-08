class UpdateVacationAndNotAvailableStandups < ActiveRecord::Migration
  def change
    Standup.where(yesterday: 'Vacation').update_all(yesterday: nil, state: Standup::VACATION)
    Standup.where(yesterday: 'Not Available').update_all(yesterday: nil, state: Standup::NOT_AVAILABLE)
    Standup.where(state: 'completed').update_all(state: Standup::DONE)
  end
end

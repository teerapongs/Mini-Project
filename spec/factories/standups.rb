FactoryGirl.define do
  factory :standup do
    user
    channel

    trait :idle do
      state Standup::IDLE
    end

    trait :active do
      state Standup::ACTIVE
    end

    trait :answering do
      state Standup::ANSWERING
    end

    trait :completed do
      state { [Standup::DONE, Standup::NOT_AVAILABLE, Standup::VACATION].sample }
    end
  end
end

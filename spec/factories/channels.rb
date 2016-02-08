FactoryGirl.define do
  factory :channel do
    name     { Faker::Name.name }
    slack_id { Faker::Number.number(10) }

    trait :active do
      state :active
    end

    trait :idle do
      state :idle
    end
  end
end

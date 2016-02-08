FactoryGirl.define do
  factory :user do
    slack_id   { Faker::Number.number(10) }
    full_name  { Faker::Name.name }
    email      { Faker::Internet.email }

    trait :admin do
      admin true
    end

    trait :bot do
      bot true
    end

    trait :disabled do
      disabled true
    end

    trait :enabled do
      disabled false
    end
  end
end

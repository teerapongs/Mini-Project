FactoryGirl.define do
  factory :setting do
    name     { Faker::Lorem.word }
    bot_id   { Faker::Number.number(10) }
    bot_name { Faker::Name.name }
    web_url  { Faker::Internet.email }
  end
end

FactoryBot.define do
  factory :expense do
    description { "Test expense" }
    amount      { 100.0 }
    date        { Date.today }

    association :paid_by, factory: :user
  end
end

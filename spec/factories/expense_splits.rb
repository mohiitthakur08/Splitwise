FactoryBot.define do
  factory :expense_split do
    amount   { 50.0 }
    user    
    expense 
  end
end

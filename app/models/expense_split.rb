class ExpenseSplit < ApplicationRecord
  belongs_to :user
  belongs_to :expense
end

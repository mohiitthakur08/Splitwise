class ExpenseItem < ApplicationRecord
  belongs_to :expense
  has_many :item_splits, dependent: :destroy
  accepts_nested_attributes_for :item_splits, allow_destroy: true

end
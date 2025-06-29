require 'rails_helper'

RSpec.describe Expense, type: :model do
  let(:paid_by) { create(:user) }
  let(:user1) { create(:user) }
  let(:user2) { create(:user) }
  let(:expense) { create(:expense, amount: 90.0, paid_by: paid_by) }

  it 'splits equally' do
    expense.apply_split(split_type: 'equal', user_ids: [user1.id, user2.id])
    expect(expense.expense_splits.size).to eq(3)
  end

  it 'splits with fixed amounts' do
    expense.apply_split(
      split_type: 'fixed',
      user_ids: [user1.id, user2.id],
      custom_split: {
        user1.id => 30,
        user2.id => 30,
        paid_by.id => 30
      }
    )
    expect(expense.expense_splits.sum(&:amount)).to eq(90.0)
  end

  it 'splits by percentage' do
    expense.apply_split(
      split_type: 'percentage',
      user_ids: [user1.id, user2.id],
      custom_split: {
        user1.id => 40,
        user2.id => 30,
        paid_by.id => 30
      }
    )
    expect(expense.expense_splits.sum(&:amount)).to eq(90.0)
  end

  it 'splits by share' do
    expense.apply_split(
      split_type: 'share',
      user_ids: [user1.id, user2.id],
      custom_split: {
        user1.id => 2,
        user2.id => 1,
        paid_by.id => 1
      }
    )
    expect(expense.expense_splits.sum(&:amount)).to eq(90.0)
  end

  it 'raises error for invalid split type' do
    expect {
      expense.apply_split(split_type: 'invalid', user_ids: [user1.id])
    }.to raise_error("Invalid split type")
  end
end

require 'rails_helper'

RSpec.describe User, type: :model do
  let(:user)   { create(:user) }
  let(:friend) { create(:user) }

  it 'returns total_owed' do
    expense = create(:expense, amount: 100, paid_by: friend)
    create(:expense_split, expense: expense, user: user, amount: 50)
    expect(user.total_owed).to eq(50)
  end

  it 'returns total_due' do
    expense = create(:expense, amount: 100, paid_by: user)
    create(:expense_split, expense: expense, user: friend, amount: 40)
    expect(user.total_due).to eq(40)
  end

  it 'returns net_balance' do
    allow(user).to receive(:total_due).and_return(70)
    allow(user).to receive(:total_owed).and_return(30)
    expect(user.net_balance).to eq(40.0)
  end

  it 'returns friends_you_owe' do
    expense = create(:expense, amount: 90, paid_by: friend)
    create(:expense_split, expense: expense, user: user, amount: 60)
    expect(user.friends_you_owe).to eq({ friend.id => 60 })
  end

  it 'returns friends_owe_you' do
    expense = create(:expense, amount: 80, paid_by: user)
    create(:expense_split, expense: expense, user: friend, amount: 50)
    expect(user.friends_owe_you).to eq({ friend.id => 50 })
  end

  it 'returns shared_expenses_with friend' do
    expense = create(:expense, amount: 100, paid_by: friend)
    create(:expense_split, expense: expense, user: user, amount: 40)
    expect(user.shared_expenses_with(friend)).to include(expense)
  end
end

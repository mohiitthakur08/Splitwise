# spec/controllers/static_controller_spec.rb
require 'rails_helper'

RSpec.describe StaticController, type: :controller do
  include Devise::Test::ControllerHelpers

  let(:user) { create(:user) }
  let(:friend) { create(:user) }

  before { sign_in user }

  describe "GET #dashboard" do
    it "assigns current_user balances correctly" do
      expense = Expense.create!(
        description: "Dinner",
        amount: 100,
        paid_by: user,
        date: Date.today
      )

      ExpenseSplit.create!(expense: expense, user: user, amount: 50)
      ExpenseSplit.create!(expense: expense, user: friend, amount: 50)

      get :dashboard

      expect(assigns(:total_balance)).to eq(user.net_balance)
      expect(assigns(:you_owe)).to eq(user.total_owed.round(2))
      expect(assigns(:you_are_owed)).to eq(user.total_due.round(2))
    end
  end
end

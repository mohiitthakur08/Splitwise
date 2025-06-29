require 'rails_helper'

RSpec.describe ExpensesController, type: :controller do
  let(:user) { create(:user) }
  let(:friend) { create(:user) }

  before { sign_in user }

  describe "POST #create" do
    let(:valid_params) do
      {
        description: "Dinner",
        amount: 100,
        date: Date.today,
        paid_by_id: user.id,
        user_ids: [user.id, friend.id],
        split_type: "equal"
      }
    end

    it "creates a new expense and redirects" do
      expect {
        post :create, params: valid_params
      }.to change(Expense, :count).by(1)

      expect(response).to redirect_to(dashboard_path)
      expect(flash[:notice]).to match("Expense added successfully")
    end
  end
end

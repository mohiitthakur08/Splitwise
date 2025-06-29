class ExpensesController < ApplicationController
  before_action :authenticate_user!

  def index
    @users = User.where.not(id: current_user.id)

    @expenses = Expense
                  .joins(:expense_splits)
                  .where(expense_splits: { user_id: current_user.id })
                  .or(Expense.where(paid_by_id: current_user.id))
                  .distinct
                  .order(date: :desc)
  end

  def new
    @users = User.where.not(id: current_user.id)
    @expense = Expense.new
  end

  def create
    ActiveRecord::Base.transaction do
      @expense = Expense.create!(
        description: params[:description],
        amount: params[:amount],
        date: params[:date],
        paid_by_id: params[:paid_by_id]
      )

      user_ids = params[:user_ids].map(&:to_i)
      custom_split = params[:custom_split]&.transform_keys(&:to_i)
      split_type = params[:split_type]

      @expense.apply_split(
        split_type: split_type,
        user_ids: user_ids,
        custom_split: custom_split
      )
    end

    redirect_to dashboard_path, notice: "Expense added successfully"
  rescue => e
    flash[:alert] = "Error: #{e.message}"
    redirect_to dashboard_path(open_modal: true)
  end

  def destroy
    @expense = Expense.find(params[:id])
    @expense.destroy
    redirect_to expenses_path, notice: "Expense deleted successfully."
  end

  def settle_up
    friend = User.find(params[:user_id])
    amount = params[:amount].to_f
    date = params[:date].presence || Date.today

    expense = Expense.create!(
      description: "Settlement with #{friend.name}",
      amount: amount,
      date: date,
      paid_by: current_user
    )

    ExpenseSplit.create!(
      expense: expense,
      user: friend,
      amount: amount
    )

    redirect_to dashboard_path, notice: "You settled ₹#{amount} with #{friend.name}."
  end
end

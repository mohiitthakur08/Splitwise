class ExpensesController < ApplicationController
  before_action :authenticate_user!

  def index
    @users = User.where.not(id: current_user.id)
    paid_expenses = Expense.where(paid_by_id: current_user.id)
    split_expenses = Expense.joins(:expense_splits).where(expense_splits: { user_id: current_user.id })
    @expenses = (paid_expenses + split_expenses).uniq.sort_by(&:date).reverse
  end

  def new
    @users = User.where.not(id: current_user.id)
    @expense = Expense.new
  end

  def create
    Expense.create_simple!(
      description: params[:description],
      amount: params[:amount],
      date: params[:date],
      paid_by_id: params[:paid_by_id],
      user_ids: params[:user_ids],
      split_type: params[:split_type],
      custom_split: params[:custom_split]
    )
    redirect_to dashboard_path, notice: "Expense added successfully"
  rescue => e
    redirect_to dashboard_path(open_modal: true), alert: "Error: #{e.message}"
  end

  def create_itemized
    Expense.create_itemized!(params, current_user)
    redirect_to dashboard_path, notice: "Itemized expense added successfully"
  rescue => e
    redirect_to dashboard_path(open_itemized_modal: true), alert: "Error: #{e.message}"
  end

  def destroy
    Expense.find(params[:id]).destroy
    redirect_to expenses_path, notice: "Expense deleted successfully."
  end

  def settle_up
    friend = User.find(params[:user_id])
    amount = params[:amount].to_f
    date = params[:date].presence || Date.today

    settled_amount = Expense.settle_between_users!(
      payer: current_user,
      receiver: friend,
      amount: amount,
      date: date
    )

    if settled_amount > 0
      redirect_to dashboard_path, notice: "You settled ₹#{settled_amount} with #{friend.name}."
    else
      redirect_to dashboard_path, alert: "No matching debts found to settle."
    end
  end
end

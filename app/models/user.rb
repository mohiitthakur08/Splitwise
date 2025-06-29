class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable

  has_many :expenses, foreign_key: :paid_by_id
  has_many :expense_splits
  has_many :split_expenses, through: :expense_splits, source: :expense

  def total_owed
    ExpenseSplit.joins(:expense)
                .where(user_id: id)
                .where.not(expenses: { paid_by_id: id })
                .sum(:amount)
  end

  def total_due
    ExpenseSplit.joins(:expense)
                .where(expenses: { paid_by_id: id })
                .where.not(user_id: id)
                .sum(:amount)
  end

  def net_balance
    (total_due - total_owed).round(2)
  end

  def friends_you_owe
    ExpenseSplit.joins(:expense)
                .where(user_id: id)
                .where.not(expenses: { paid_by_id: id })
                .group('expenses.paid_by_id')
                .sum(:amount)
  end

  def friends_owe_you
    ExpenseSplit.joins(:expense)
                .where(expenses: { paid_by_id: id })
                .where.not(user_id: id)
                .group(:user_id)
                .sum(:amount)
  end

  def shared_expenses_with(friend)
    Expense
      .joins(:expense_splits)
      .where("(expenses.paid_by_id = :you AND expense_splits.user_id = :friend)
              OR (expenses.paid_by_id = :friend AND expense_splits.user_id = :you)",
              you: id, friend: friend.id)
      .distinct
      .order(date: :desc)
  end
end

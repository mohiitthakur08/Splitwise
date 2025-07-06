class Expense < ApplicationRecord
  belongs_to :paid_by, class_name: 'User'
  has_many :expense_splits, dependent: :destroy
  has_many :users, through: :expense_splits
  has_many :expense_items, dependent: :destroy
  accepts_nested_attributes_for :expense_items, allow_destroy: true

  def self.create_simple!(description:, amount:, date:, paid_by_id:, user_ids:, split_type:, custom_split:)
    ActiveRecord::Base.transaction do
      expense = Expense.create!(
        description: description,
        amount: amount,
        date: date,
        paid_by_id: paid_by_id
      )

      user_ids = user_ids.map(&:to_i)
      custom_split = custom_split&.transform_keys(&:to_i)
      expense.apply_split(split_type: split_type, user_ids: user_ids, custom_split: custom_split)
    end
  end

  def self.create_itemized!(params, current_user)
    ActiveRecord::Base.transaction do
      expense = Expense.create!(
        description: params[:description],
        date: params[:date],
        paid_by_id: params[:paid_by_id],
        tax: params[:tax].presence || 0
      )

      total_split_map = Hash.new(0)

      params[:items]&.each do |_, item_params|
        item_name = item_params[:name]
        item_amount = item_params[:amount].to_f
        user_ids = item_params[:user_ids]&.map(&:to_i) || []

        raise "Please select at least one user for item '#{item_name}'" if user_ids.empty?

        item = expense.expense_items.create!(name: item_name, amount: item_amount)

        per_user = (item_amount / user_ids.size).round(2)
        remainder = expense.remainder(per_user, item_amount, user_ids.size)

        user_ids.each_with_index do |uid, idx|
          final_amt = idx == 0 ? (per_user + remainder) : per_user
          item.item_splits.create!(user_id: uid, amount: final_amt)
          total_split_map[uid] += final_amt
        end
      end

      if expense.tax.to_f > 0
        tax = expense.tax.to_f
        ids = total_split_map.keys
        per_tax = (tax / ids.size).round(2)
        remainder_tax = expense.remainder(per_tax, tax, ids.size)

        ids.each_with_index do |uid, idx|
          total_split_map[uid] += (idx == 0 ? per_tax + remainder_tax : per_tax)
        end
      end

      total_split_map.each do |uid, amt|
        expense.expense_splits.create!(user_id: uid, amount: amt.round(2))
      end

      expense.update!(amount: total_split_map.values.sum.round(2))
    end
  end

  def self.settle_between_users!(payer:, receiver:, amount:, date:)
    return 0 if amount <= 0

    splits = Expense
      .where(paid_by_id: receiver.id)
      .joins(:expense_splits)
      .where(expense_splits: { user_id: payer.id })
      .order(:date)

    remaining = amount

    ActiveRecord::Base.transaction do
      splits.each do |expense|
        split = expense.expense_splits.find_by(user_id: payer.id)
        next unless split && split.amount.positive?

        if split.amount <= remaining
          remaining -= split.amount
          split.destroy
        else
          split.update!(amount: (split.amount - remaining).round(2))
          remaining = 0
          break
        end
      end
    end

    amount - remaining
  end

  def apply_split(split_type:, user_ids:, custom_split: {})
    user_ids = user_ids.map(&:to_i)
    user_ids << paid_by_id unless user_ids.include?(paid_by_id)

    case split_type
    when "equal"
      count = user_ids.size
      split_amt = (amount.to_f / count).round(2)
      rem = remainder(split_amt, amount.to_f, count)

      user_ids.each_with_index do |uid, i|
        expense_splits.create!(user_id: uid, amount: i == 0 ? (split_amt + rem) : split_amt)
      end

    when "fixed"
      user_ids.each { |uid| expense_splits.create!(user_id: uid, amount: custom_split[uid].to_f) }

    when "percentage"
      user_ids.each do |uid|
        pct = custom_split[uid].to_f
        amt = ((amount.to_f * pct) / 100).round(2)
        expense_splits.create!(user_id: uid, amount: amt)
      end

    when "share"
      shares = custom_split.values.map(&:to_f).sum
      raise "Total shares must be greater than 0" if shares == 0

      user_ids.each do |uid|
        ratio = custom_split[uid].to_f / shares
        amt = (ratio * amount.to_f).round(2)
        expense_splits.create!(user_id: uid, amount: amt)
      end

    else
      raise "Invalid split type"
    end
  end

  private

  def remainder(per_user, total, count)
    (total - (per_user * count)).round(2)
  end
end

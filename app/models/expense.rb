class Expense < ApplicationRecord
  belongs_to :paid_by, class_name: 'User'
  has_many :expense_splits, dependent: :destroy
  has_many :users, through: :expense_splits
  
  def apply_split(split_type:, user_ids:, custom_split: {})
    user_ids = user_ids.map(&:to_i)
    user_ids << self.paid_by_id unless user_ids.include?(self.paid_by_id)

    case split_type
    when "equal"
      split_count = user_ids.size
      split_amount = (amount.to_f / split_count).round(2)

      user_ids.each_with_index do |uid, index|
        final_amt = index == 0 ? (split_amount + remainder(split_amount, amount.to_f, split_count)) : split_amount
        expense_splits.create!(user_id: uid, amount: final_amt)
      end

    when "fixed"
      user_ids.each do |uid|
        expense_splits.create!(user_id: uid, amount: custom_split[uid].to_f)
      end

    when "percentage"
      user_ids.each do |uid|
        pct = custom_split[uid].to_f
        amt = ((amount.to_f * pct) / 100).round(2)
        expense_splits.create!(user_id: uid, amount: amt)
      end

    when "share"
      total_shares = custom_split.values.map(&:to_f).sum
      raise "Total shares must be greater than 0" if total_shares == 0

      user_ids.each do |uid|
        share_amt = ((custom_split[uid].to_f / total_shares) * amount.to_f).round(2)
        expense_splits.create!(user_id: uid, amount: share_amt)
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

class AddTaxToExpenses < ActiveRecord::Migration[6.1]
  def change
    add_column :expenses, :tax, :decimal
  end
end

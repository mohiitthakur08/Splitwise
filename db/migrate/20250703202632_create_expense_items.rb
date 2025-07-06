class CreateExpenseItems < ActiveRecord::Migration[6.1]
  def change
    create_table :expense_items do |t|
      t.string :name
      t.decimal :amount
      t.references :expense, null: false, foreign_key: true

      t.timestamps
    end
  end
end

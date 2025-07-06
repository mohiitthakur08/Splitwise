class CreateItemSplits < ActiveRecord::Migration[6.1]
  def change
    create_table :item_splits do |t|
      t.references :user, null: false, foreign_key: true
      t.references :expense_item, null: false, foreign_key: true
      t.decimal :amount

      t.timestamps
    end
  end
end

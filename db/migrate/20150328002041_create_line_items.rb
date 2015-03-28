class CreateLineItems < ActiveRecord::Migration
  def change
    create_table :line_items do |t|
      t.belongs_to :invoice, index: true

      t.integer :amount_cents,    default: 0,     null: false
      t.string  :amount_currency, default: "USD", null: false
      t.string  :description
      t.integer :quantity,        default: 1

      t.datetime :deleted_at, index: true
      t.timestamps null: false
    end
  end
end

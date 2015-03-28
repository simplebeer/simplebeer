class CreateInvoices < ActiveRecord::Migration
  def change
    create_table :invoices do |t|
      t.belongs_to :payment_method, index: true, polymorphic: true
      t.belongs_to :subscriber,     index: true, polymorphic: true
      t.belongs_to :subscription,   index: true

      t.datetime :due_at
      t.boolean  :paid,           default: false
      t.datetime :period_start
      t.datetime :period_end
      t.integer  :total_cents,    default: 0,     null: false
      t.string   :total_currency, default: "USD", null: false

      t.datetime :deleted_at, index: true
      t.timestamps null: false
    end
  end
end

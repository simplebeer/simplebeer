class CreateSubscriptions < ActiveRecord::Migration
  def change
    create_table :subscriptions do |t|
      t.belongs_to :subscription_plan, index: true
      t.belongs_to :subscriber,        polymorphic: true
      t.belongs_to :payment_method,    polymorphic: true

      t.boolean  :auto_renew,           default: true
      t.boolean  :cancel_at_period_end, default: true
      t.datetime :current_period_start
      t.datetime :current_period_end
      t.datetime :canceled_at
      t.datetime :ended_at
      t.integer  :status,               default: 0
      t.datetime :trial_ends_at

      t.datetime :deleted_at, index: true
      t.timestamps null: false
    end

    add_index :subscriptions, [:subscriber_id, :subscriber_type],         name: "index_invoices_on_subscriber_id_and_type"
    add_index :subscriptions, [:payment_method_id, :payment_method_type], name: "index_invoices_on_payment_method_id_and_type"
  end
end

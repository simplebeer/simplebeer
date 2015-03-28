class CreateSubscriptionPlans < ActiveRecord::Migration
  def change
    create_table :subscription_plans do |t|
      t.boolean :active,            default: false
      t.integer :account_type,      default: 0
      t.string  :color
      t.integer :interval,          default: 0
      t.integer :interval_count,    default: 1
      t.string  :name
      t.string  :reference_code
      t.integer :trial_period_days, default: 0

      t.integer :price_cents,             default: 0,     null: false
      t.string  :price_currency,          default: "USD", null: false

      t.integer :price_per_user_cents,    default: 0,     null: false
      t.string  :price_per_user_currency, default: "USD", null: false

      t.integer :setup_price_cents,       default: 0,     null: false
      t.string  :setup_price_currency,    default: "USD", null: false

      t.timestamps null: false
    end
  end
end

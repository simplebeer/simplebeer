class CreateOrganizations < ActiveRecord::Migration
  def change
    create_table :organizations do |t|
      t.integer :account_balance_cents,    default: 0,     null: false
      t.string  :account_balance_currency, default: "USD", null: false
      t.string  :name
      t.string  :time_zone

      t.datetime :deleted_at, index: true
      t.timestamps null: false
    end
  end
end

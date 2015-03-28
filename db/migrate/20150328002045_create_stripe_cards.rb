class CreateStripeCards < ActiveRecord::Migration
  def change
    create_table :stripe_cards do |t|
      t.belongs_to :subscriber, index: true, polymorphic: true

      t.string  :stripe_card_id
      t.string  :stripe_customer_id
      t.string  :stripe_token
      t.string  :last4
      t.string  :brand
      t.integer :exp_month
      t.integer :exp_year

      t.datetime :deleted_at, index: true
      t.timestamps null: false
    end
  end
end

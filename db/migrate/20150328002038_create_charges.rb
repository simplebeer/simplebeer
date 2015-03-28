class CreateCharges < ActiveRecord::Migration
  def change
    create_table :charges do |t|
      t.belongs_to :invoice,        index: true
      t.belongs_to :payment_method, index: true, polymorphic: true

      t.string  :error_message
      t.integer :status

      t.datetime :deleted_at, index: true
      t.timestamps null: false
    end
  end
end

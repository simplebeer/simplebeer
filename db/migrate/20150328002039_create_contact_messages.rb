class CreateContactMessages < ActiveRecord::Migration
  def change
    create_table :contact_messages do |t|
      t.string :name
      t.string :email
      t.string :phone_number
      t.text   :message

      t.timestamps null: false
    end
  end
end

class CreateOmniAuthProviders < ActiveRecord::Migration
  def change
    create_table :omni_auth_providers do |t|
      t.belongs_to :subscriber, index: true, polymorphic: true

      t.jsonb   :auth_data
      t.string  :name
      t.string  :uid

      t.timestamps null: false
    end
  end
end

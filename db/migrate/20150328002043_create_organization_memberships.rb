class CreateOrganizationMemberships < ActiveRecord::Migration
  def change
    create_table :organization_memberships do |t|
      t.belongs_to :organization, index: true
      t.belongs_to :user,         index: true

      t.integer :role, default: 0

      t.timestamps null: false
    end
  end
end

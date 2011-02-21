class CreateAdministrators < ActiveRecord::Migration
  def self.up
    create_table :administrators do |t|
      t.integer     :organization_id
      t.string      :name
      t.string      :email
      t.integer     :account_id
      t.datetime    :deleted_at
      t.timestamps
    end
  end

  def self.down
    drop_table :administrators
  end
end

class CreateRecipientGroups < ActiveRecord::Migration
  def self.up
    create_table :recipient_groups do |t|
      t.integer     :organization_id
      t.integer     :recipient_id
      t.integer     :group_id
      t.timestamps
    end
  end

  def self.down
    drop_table :recipient_groups
  end
end

class CreateMailGroups < ActiveRecord::Migration
  def self.up
    create_table :mail_groups do |t|
      t.integer     :organization_id
      t.integer     :mail_summary_id
      t.integer     :group_id
      t.timestamps
    end
  end

  def self.down
    drop_table :mail_groups
  end
end

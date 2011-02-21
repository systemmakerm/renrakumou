class CreateSentGroups < ActiveRecord::Migration
  def self.up
    create_table :sent_groups do |t|
      t.integer     :organization_id
      t.integer     :mail_summary_id
      t.string      :group_name
      t.timestamps
    end
  end

  def self.down
    drop_table :sent_groups
  end
end

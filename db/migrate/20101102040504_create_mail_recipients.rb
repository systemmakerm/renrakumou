class CreateMailRecipients < ActiveRecord::Migration
  def self.up
    create_table :mail_recipients do |t|
      t.integer     :organization_id
      t.integer     :mail_summary_id
      t.integer     :recipient_id
      t.timestamps
    end
  end

  def self.down
    drop_table :mail_recipients
  end
end

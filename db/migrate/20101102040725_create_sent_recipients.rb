class CreateSentRecipients < ActiveRecord::Migration
  def self.up
    create_table :sent_recipients do |t|
      t.integer     :organization_id
      t.integer     :mail_summary_id
      t.string      :recipient_name
      t.timestamps
    end
  end

  def self.down
    drop_table :sent_recipients
  end
end

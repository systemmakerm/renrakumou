class CreateErrorMails < ActiveRecord::Migration
  def self.up
    create_table :error_mails do |t|
      t.integer     :organization_id
      t.integer     :mail_summary_id
      t.integer     :recipient_id
      t.text        :error_code
      t.timestamps
    end
  end

  def self.down
    drop_table :error_mails
  end
end

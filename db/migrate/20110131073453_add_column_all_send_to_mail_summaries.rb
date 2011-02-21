class AddColumnAllSendToMailSummaries < ActiveRecord::Migration
  def self.up
    add_column :mail_summaries,   :all_send,  :integer
    add_column :mail_summaries,   :relation,  :integer
  end

  def self.down
    remove_column :mail_summaries,   :all_send
    remove_column :mail_summaries,   :relation
  end
end

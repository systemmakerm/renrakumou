class CreateMailSummaries < ActiveRecord::Migration
  def self.up
    create_table :mail_summaries do |t|
      t.integer     :organization_id
      t.string      :subject
      t.text        :body
      t.string      :address_for_map
      t.datetime    :deleted_at
      t.timestamps
    end
  end

  def self.down
    drop_table :mail_summaries
  end
end

class CreateAnswers < ActiveRecord::Migration
  def self.up
    create_table :answers do |t|
      t.integer     :organization_id
      t.integer     :mail_summary_id
      t.integer     :recipient_id
      t.integer     :number
      t.timestamps
    end
  end

  def self.down
    drop_table :answers
  end
end

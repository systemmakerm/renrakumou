class CreateSelections < ActiveRecord::Migration
  def self.up
    create_table :selections do |t|
      t.integer     :organization_id
      t.integer     :mail_summary_id
      t.integer     :number
      t.string      :body
      t.timestamps
    end
  end

  def self.down
    drop_table :selections
  end
end

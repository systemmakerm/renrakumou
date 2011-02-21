class CreateDeliveryTimes < ActiveRecord::Migration
  def self.up
    create_table :delivery_times do |t|
      t.integer     :organization_id
      t.integer     :mail_summary_id
      t.datetime    :delivery_time
      t.timestamps
    end
  end

  def self.down
    drop_table :delivery_times
  end
end

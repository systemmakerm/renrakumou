class CreateDeliveryReserveTimes < ActiveRecord::Migration
  def self.up
    create_table :delivery_reserve_times do |t|
      t.integer     :organization_id
      t.integer     :mail_summary_id
      t.datetime    :delivery_reserve_time
      t.timestamps
    end
  end

  def self.down
    drop_table :delivery_reserve_times
  end
end

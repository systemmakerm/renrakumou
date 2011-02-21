class CreateUsers < ActiveRecord::Migration
  def self.up
    create_table :users do |t|
      t.integer     :organization_id
      t.integer     :number
      t.string      :name
      t.text        :memo
      t.datetime    :deleted_at
      t.timestamps
    end
  end

  def self.down
    drop_table :users
  end
end

class CreateChnames < ActiveRecord::Migration
  def self.up
    create_table :chnames do |t|
      t.string     :address
      t.string     :goto
      t.timestamps
    end
  end

  def self.down
    drop_table :chnames
  end
end

class CreateMailboxes < ActiveRecord::Migration
  def self.up
    create_table :mailboxes do |t|
      t.string      :maildir
      t.string      :username
      t.timestamps
    end
  end

  def self.down
    drop_table :mailboxes
  end
end

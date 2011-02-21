class CreateRecipients < ActiveRecord::Migration
  def self.up
    create_table :recipients do |t|
      t.integer     :organization_id
      t.integer     :user_id
      t.integer     :account_id
      t.string      :name
      t.string      :email
      t.string      :tel1,   :limit => 100
      t.string      :tel2,   :limit => 100
      t.string      :relation
      t.datetime    :deleted_at
      t.timestamps
    end
  end

  def self.down
    drop_table :recipients
  end
end

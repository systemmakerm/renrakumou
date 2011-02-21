class CreateOrganizations < ActiveRecord::Migration
  def self.up
    create_table :organizations do |t|
      t.integer   :login
      t.integer   :account_id
      t.string    :name
      t.string    :leader_name
      t.string    :kana
      t.integer   :sex
      t.string    :zip,   :limit => 8
      t.string    :prefecture
      t.string    :address1
      t.string    :address2
      t.string    :tel,   :limit => 100
      t.string    :fax,   :limit => 100
      t.string    :email
      t.text      :purpose
      t.date      :valid_date
      t.datetime  :deleted_at
      t.timestamps
    end
    add_index      :organizations,   :login,   :unique => true
  end

  def self.down
    drop_table :organizations
  end
end

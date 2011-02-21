class AddColumnLoginToAccounts < ActiveRecord::Migration
  def self.up
    add_column :accounts,  :login,  :string, :limit => 40
    add_column :accounts,  :status,  :integer
  end

  def self.down
    remove_column :accounts,  :login
    remove_column :accounts,  :status
  end
end

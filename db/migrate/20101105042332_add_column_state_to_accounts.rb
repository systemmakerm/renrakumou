class AddColumnStateToAccounts < ActiveRecord::Migration
  def self.up
    add_column :accounts,   :activation_code,           :string, :limit => 40
    add_column :accounts,   :activated_at,              :datetime
    add_column :accounts,   :state,                     :string, :null => :no, :default => 'passive'
  end

  def self.down
    remove_column :accounts,   :activation_code
    remove_column :accounts,   :activated_at
    remove_column :accounts,   :state
  end
end

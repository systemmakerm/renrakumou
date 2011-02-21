class RemoveColumnLoginFromOrganizations < ActiveRecord::Migration
  def self.up
    remove_column :organizations,  :login
  end

  def self.down
    add_column :organizations,  :login, :integer
  end
end

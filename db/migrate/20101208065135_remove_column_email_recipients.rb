class RemoveColumnEmailRecipients < ActiveRecord::Migration
  def self.up
    remove_column :recipients,  :email
  end

  def self.down
    add_column :recipients,  :email,  :string
  end
end

class ChangeNumberTypeUsers < ActiveRecord::Migration
  def self.up
    remove_column :users,  :number
    add_column    :users,  :number, :string
  end

  def self.down
    remove_column :users,  :number
    add_column    :users,  :number, :integer
  end
end

class AddColumnLftRhtGroups < ActiveRecord::Migration
  def self.up
    remove_column :groups,  :parent_group_id
    add_column    :groups,  :parent_id,   :integer
    add_column    :groups,  :lft,         :integer
    add_column    :groups,  :rgt,         :integer
  end

  def self.down
    add_column :groups,  :parent_group_id,  :integer
    remove_column :groups,  :parent_id
    remove_column :groups,  :lft
    remove_column :groups,  :rgt
  end
end

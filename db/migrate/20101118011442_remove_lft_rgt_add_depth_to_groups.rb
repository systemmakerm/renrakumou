class RemoveLftRgtAddDepthToGroups < ActiveRecord::Migration
  def self.up
    remove_column :groups,  :lft
    remove_column :groups,  :rgt
    add_column   :groups,  :depth,  :integer
  end

  def self.down
    add_column :groups,  :lft,  :integer
    add_column :groups,  :rgt,  :integer
    remove_column   :groups,  :depth
  end
end

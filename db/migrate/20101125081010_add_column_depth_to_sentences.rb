class AddColumnDepthToSentences < ActiveRecord::Migration
  def self.up
    add_column  :sentences, :depth, :integer
  end

  def self.down
    remove_column :sentences, :depth
  end
end

class CreateSentences < ActiveRecord::Migration
  def self.up
    create_table :sentences do |t|
      t.integer     :organization_id
      t.string      :group_name
      t.integer     :parent_sentence_id
      t.string      :subject
      t.string      :body
      t.datetime    :deleted_at
      t.timestamps
    end
  end

  def self.down
    drop_table :sentences
  end
end

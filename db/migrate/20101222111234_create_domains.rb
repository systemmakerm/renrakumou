class CreateDomains < ActiveRecord::Migration
  def self.up
    create_table :domains do |t|
      t.integer     :organization_id
      t.integer     :chname_id
      t.string      :virtual_domain
      t.timestamps
    end
  end

  def self.down
    drop_table :domains
  end
end

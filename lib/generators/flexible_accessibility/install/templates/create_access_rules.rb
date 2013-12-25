class CreateAccessRules < ActiveRecord::Migration
  def self.up
    create_table :access_rules do |t|
      t.string  :permission
      t.integer :owner_id
      t.timestamps

      t.index [:owner_id], :name => 'access_rules_index_on_owner_id'
    end
  end

  def self.down
    drop_table :access_rules
  end
end
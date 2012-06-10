class CreatePermissions < ActiveRecord::Migration
	def up
		create_table :permissions do |t|
			t.string :action, :null => false
			t.integer :user_id, :null => false
      t.timestamps
		end

		add_index :permissions, :user_id
	end

	def down
		drop_table :permissions
	end
end
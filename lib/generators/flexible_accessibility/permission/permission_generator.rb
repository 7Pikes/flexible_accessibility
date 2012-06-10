module FlexibleAccessibilty
	module Generators
		class PermissionGenerator < Rails::Generators::Base
      source_root File.expand_path('../templates', __FILE__)

      def generate_ability
        copy_file "permission.rb", "app/models/permission.rb"
        copy_file "create_permissions.rb", "db/migrate/create_permissions.rb"
      end
    end
	end
end
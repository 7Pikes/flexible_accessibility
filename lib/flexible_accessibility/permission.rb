module FlexibleAccessibility
  class Permission
  	class << self
	  def all
		permissions = {}
		Utils.new.get_controllers.each do |klass|
		  permissions[klass.to_sym] = klass.camelize.constantize.instance_variable_get(:@_checkable_routes).collect{ |a| a.to_s }.join(', ')
		end
		permissions
	  end

      # Stub methods
	  def is_action_permitted? action
	  	false
	  end

	  def is_action_permitted_for_user? action, user
	  	false 
	  end
	end
  end
end

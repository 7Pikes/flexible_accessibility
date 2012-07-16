module FlexibleAccessibility
  class Permissions
  	class << self
	  def get_permissions
		permissions = {}
		ApplicationController.subclasses.each do |klass|
		  permissions[klass.to_s.tableize.singularize.to_sym] = klass.instance_variable_get(:@checkable_routes).collect{ |a| a.to_s }.join(', ')
		end
		permissions
	  end

	  def is_action_permitted? action
	  end

	  def is_action_permitted_for_user? action, user
	  	!self.where(["action = ? and user_id = ?", action, user.id]).empty?
	  end
	end
  end
end

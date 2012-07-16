module FlexibleAccessibility
  class Permissions
  	class << self
	  def get_permissions
		permissions = {}
		Utils.new.get_controllers.each do |klass|
		  permissions[klass.to_sym] = klass.camelize.constantize.instance_variable_get(:@_checkable_routes).collect{ |a| a.to_s }.join(', ')
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
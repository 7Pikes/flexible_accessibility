module FlexibleAccessibility
  module Filters
  	extend ActiveSupport::Concern

  	included do
  	  append_before_filter :check_permission_to_route
  	  append_before_filter :check_if_route_permitted
  	end
	  
	# We checks access to route
	# And we expected the existing of current_user helper
	def check_permission_to_route
	  if self.class.instance_variable_get(:@_checkable_routes).include? current_action.to_sym
	    self.class.instance_variable_set(:@_route_permitted, true) unless Permissions.is_action_permitted_for_user? current_route, current_user
	  end
	end

	# We checks @authorized variable state
	def check_if_route_permitted
	  raise FlexibleAccessibility::AccessDeniedException unless self.class.instance_variable_get :@_route_permitted
	end
  end

  ActiveSupport.on_load(:action_controller) do
    ActionController::Base.send(:include, Filters)
  end
end
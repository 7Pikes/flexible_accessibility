module FlexibleAccessibility
  module Filters
  	extend ActiveSupport::Concern

  	included do
  	  append_before_filter(:check_permission_to_route)
  	  append_before_filter(:check_if_route_is_permitted)
  	end
	  
	  private
    # Detect current controller and action and return a permission
    def current_resource
      # ActionController::Routing::Routes.recognize_path request.env["PATH_INFO"][:controller]
      params[:controller]
    end

    def current_action
      # ActionController::Routing::Routes.recognize_path request.env["PATH_INFO"][:action]
      params[:action]
    end

    def current_route
      "#{current_resource}##{current_action}"
    end

  	# We checks access to route and we expected the existing of current_user helper
  	def check_permission_to_route
      if self.class.instance_variable_get(:@_verifiable_routes).include? current_action
        raise UserNotLoggedInException.new(current_route, nil) if current_user.nil?
  	    self.class.instance_variable_set(:@_route_permitted, Permission.is_action_permitted_for_user?(current_route, current_user))
      elsif self.class.instance_variable_get(:@_non_verifiable_routes).include? current_action
        self.class.instance_variable_set(:@_route_permitted, true)
      else
        self.class.instance_variable_set(:@_route_permitted, false)
  	  end
  	end

  	# We checks @authorized variable state
  	def check_if_route_is_permitted
  	  raise AccessDeniedException.new(current_route, nil) unless self.class.instance_variable_get(:@_route_permitted)
	  end
  end

  ActiveSupport.on_load(:action_controller) do
    ActionController::Base.send(:include, Filters)
  end
end

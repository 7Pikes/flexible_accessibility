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

    # Expected the existing of current_user helper
    def logged_user
      return current_user if defined?(current_user)
      raise NoWayToDetectLoggerUserException unless defined?(current_user)
    end

  	# Check access to route and we expected the existing of current_user helper
  	def check_permission_to_route
      if verifiable_routes_list.include?(current_action)
        raise UserNotLoggedInException.new(current_route, nil) if logged_user.nil?
        AccessProvider.is_action_permitted_for_user?(current_route, logged_user) ? allow_route : deny_route
      elsif non_verifiable_routes_list.include?(current_action)
        allow_route
      else
        deny_route
      end
    end

    def verifiable_routes_list
      routes_table = self.class.instance_variable_get(:@_routes_table)
        
      return available_routes_list if routes_table[:all]
      return routes_table[:only] unless routes_table[:only].nil?
      return available_routes_list - routes_table[:except] unless routes_table[:except].nil?
      return []  
    end

    def non_verifiable_routes_list
      unless routes_table[:skip].nil?
        routes_table = self.class.instance_variable_get(:@_routes_table)
        return routes_table[:skip].first == 'all' ? available_routes_list : routes_table[:skip]
      end
      return []
    end

    # TODO: Move to RouteProvider
    def available_routes_list
      available_routes = Utils.new.app_routes[self.class.to_s.gsub(/Controller/, '')]
      # available_routes = self.action_methods if available_routes.nil?
      raise NoWayToDetectAvailableRoutesException if available_routes.nil?
      available_routes.to_set
    end

    def allow_route
      self.class.instance_variable_set(:@_route_permitted, true)
    end

    def deny_route
      self.class.instance_variable_set(:@_route_permitted, false)
    end

  	# Check the @_route_permitted variable state
  	def check_if_route_is_permitted
  	  raise AccessDeniedException.new(current_route, nil) unless self.class.instance_variable_get(:@_route_permitted)
	  end
  end

  ActiveSupport.on_load(:action_controller) do
    ActionController::Base.send(:include, Filters)
  end
end

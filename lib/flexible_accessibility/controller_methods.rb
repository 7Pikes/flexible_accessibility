module FlexibleAccessibility
  module ControllerMethods
  	module ClassMethods

      # Macro for skip authorization
      def skip_authorization_here
        self.instance_variable_set :@route_permitted, true
        self.instance_variable_set :@checkable_routes, []
        self.send :before_filter, :check_if_route_permitted
      end

      # Macro for define authorization
  	  def authorize args={}
        self.instance_variable_set :@route_permitted, false
  	  	self.send :before_filter, :check_permission_to_route
        self.send :before_filter, :check_if_route_permitted
        set_actions_to_authorize args
  	  end
      
      private
      #
      def set_actions_to_authorize args={}
        self.instance_variable_set :@checkable_routes, args[:only] unless args[:only].nil?
        # TODO: understand and fix it
        self.instance_variable_set :@checkable_routes, self.action_methods - args[:except] unless args[:except].nil?  
      end

      #
      def current_route
        path = ActionController::Routing::Routes.recognize_path request.env["PATH_INFO"]
        [path[:controller], path[:action]]
      end

      # We checks access to route
      # And we expected the existing of current_user helper
      def check_permission_to_route
        if self.instance_variable_get(:@checkable_routes).include? current_route[1].to_sym
          self.instance_variable_set(:@route_permitted, true) unless Permissions.is_action_permitted_for_user? "#{current_route[0]}##{current_route[1]}", current_user
        end
      end

      # We checks @authorized variable state
      def check_if_route_permitted
        raise FlexibleAccessibility::AccessDeniedException unless self.instance_variable_get :@route_permitted
      end
    end
 
    # Callback needs for include methods and define helper method
    def self.included base
      base.extend ClassMethods
      base.helper_method :has_access?
    end
    
    # We checks url for each link in view to show it
    def has_access? controller, action
      Permissions.is_action_permitted_for_user? "#{controller}##{action}", current_user
    end
  end
end

#
if defined? ActionController::Base
	ActionController::Base.class_eval do
	  include FlexibleAccessibility::ControllerMethods	
	end
end

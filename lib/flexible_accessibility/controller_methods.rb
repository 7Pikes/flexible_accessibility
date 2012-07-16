module FlexibleAccessibility
  module ControllerMethods
  	module ClassMethods

      # Macro for skip authorization
      def skip_authorization_here
        self.instance_variable_set :@_route_permitted, true
        self.instance_variable_set :@_checkable_routes, []
        #self.send :before_filter, :check_if_route_permitted
      end

      # Macro for define authorization
  	  def authorize args={}
        self.instance_variable_set :@_route_permitted, false
  	  	#self.send :before_filter, :check_permission_to_route
        #self.send :before_filter, :check_if_route_permitted
        set_actions_to_authorize args
  	  end
      
      private
      # Set actions for authorize as instance variable
      def set_actions_to_authorize args={}
        self.instance_variable_set :@_checkable_routes, args[:only] unless args[:only].nil?
        # TODO: understand and fix it
        self.instance_variable_set :@_checkable_routes, self.action_methods - args[:except] unless args[:except].nil?  
      end
    end

    module InstanceMethods

      private
      # Detect current controller and action and return a permission
      def current_resource
        ActionController::Routing::Routes.recognize_path request.env["PATH_INFO"][:controller]
      end

      def current_action
        ActionController::Routing::Routes.recognize_path request.env["PATH_INFO"][:action]
      end

      def current_route
        "#{current_resource}##{current_action}"
      end
    end
 
    # Callback needs for include methods and define helper method
    def self.included base
      base.extend ClassMethods
      base.include InstanceMethods
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

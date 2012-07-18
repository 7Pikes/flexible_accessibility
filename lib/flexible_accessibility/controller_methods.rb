module FlexibleAccessibility
  module ControllerMethods
  	module ClassMethods

      # Macro for skip authorization
      def skip_authorization_here
        self.instance_variable_set :@_route_permitted, true
        self.instance_variable_set :@_checkable_routes, []
      end

      # Macro for define authorization
  	  def authorize args={}
        self.instance_variable_set :@_route_permitted, false
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
 
    # Callback needs for include methods and define helper method
    def self.included base
      base.extend ClassMethods
      base.helper_method :has_access?
    end
    
    # We checks url for each link in view to show it
    def has_access? permission, user
      Permission.is_action_permitted_for_user? permission, user
    end
  end
end

# We include methods in ActionController::Base
if defined? ActionController::Base
	ActionController::Base.class_eval do
	  include FlexibleAccessibility::ControllerMethods	
	end
end

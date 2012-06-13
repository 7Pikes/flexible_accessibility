module FlexibleAccessibility
  module ControllerMethods
  	module ClassMethods
      before_filter :check_access_to_resource
      before_filter :check_if_authorized

      def skip_authorization_on_resource
        @authorized = true
      end

  	  def authorize actions=[]
  	  	@actions = actions
  	  end

      def current_action
        path = ActionController::Routing::Routes.recognize_path request.env["PATH_INFO"]
        @fa_path = [path[:controller], path[:action]]
      end

      def check_access_to_resource
        if @actions.include current_action[1].to_sym
          @authorized = true unless Permission.check_access "#{current_action[0]}##{current_action[1]}", current_action
        end
      end

      def check_if_authorized
        raise FlexibleAccessibility::AccessDeniedException unless @authorized
      end
      
      def has_access? controller, action
        Permission.check_access "#{controller}##{action}", current_action
      end
    end

    def self.included base
    	base.extend ClassMethods
    	base.helper_method has_access?
    end
  end
end

if defined? ApplicationController
	ApplicationController.class_eval do
	  include FlexibleAccessibility::ControllerMethods	
	end
end

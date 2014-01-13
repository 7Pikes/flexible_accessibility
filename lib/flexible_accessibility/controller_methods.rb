module FlexibleAccessibility
  module ControllerMethods
  	module ClassMethods

      # Compatibility with previous versions
      def skip_authorization_here
        authorize :skip => :all
      end

      # Macro for define actions with authorization
  	  def authorize(args={})
        arguments = parse_arguments(args)
        validate_arguments(arguments)
        available_routes = Utils.new.app_routes[self.to_s.gsub(/Controller/, '')]
        available_routes = available_routes.to_set unless available_routes.nil?
        unless available_routes.nil?
          self.instance_variable_set(:@_verifiable_routes, available_routes) if arguments[:all]
          self.instance_variable_set(:@_verifiable_routes, arguments[:only]) unless arguments[:only].nil?
          self.instance_variable_set(:@_verifiable_routes, available_routes - arguments[:except]) unless arguments[:except].nil?
          unless arguments[:skip].nil?
            non_verifiable_routes = arguments[:skip].first == 'all' ? available_routes : arguments[:skip]
            self.instance_variable_set(:@_non_verifiable_routes, non_verifiable_routes)
          end
        end
  	  end

      private
      # Parse arguments from macro calls
      def parse_arguments(args={})
        result = {}
        (result[:all] = ['all'].to_set) and return result if args.to_s == 'all'
        [:only, :except, :skip].each do |key|
          unless args[key].nil?
            result[key] = [args[key].to_s].to_set and next if args[key].to_s == 'all' && key == :skip
            raise ActionsValueException unless args[key].instance_of?(Array)
            result[key] = args[key].map!{ |v| v.to_s }.to_set
          end
        end
        result
      end

      def validate_arguments(args={})
        return if args.count == 1 && args.keys.include?(:all)
        only_options = args[:only] || Set.new
        except_options =  args[:except] || Set.new
        skip_options = args[:skip] || Set.new
        unless (only_options & except_options).empty? &&
               (only_options & skip_options).empty?
          raise IncorrectArgumentException.new(nil, 'The same arguments shouldn\'t be used with different keys excluding except and skip')
        end
        if args[:skip] == 'all' && args.count > 1
          raise IncorrectArgumentException.new(nil, 'Option \'skip\' with argument \'all\' shouldn\'t be used with another options')
        end
      end
    end
 
    # Callback is needed for include methods and define helper method
    def self.included(base)
      base.extend(ClassMethods)
      base.helper_method(:has_access?)
    end
    
    # Check the url for each link in view to show it
    def has_access?(permission, user)
      raise UnknownUserException if user.nil?
      AccessProvider.is_action_permitted_for_user?(permission, user)
    end
  end
end

# Include methods in ActionController::Base
if defined?(ActionController::Base)
	ActionController::Base.class_eval do
	  include FlexibleAccessibility::ControllerMethods
	end
end

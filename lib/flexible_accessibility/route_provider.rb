module FlexibleAccessibility
  class RouteProvider
    @@routes ||= {}

    def initialize(controller=nil)
      @path = "#{::Rails.root}/app/controllers/"
      @controllers = {}
      @current_controller = controller
    end

    def app_controllers
      app_controllers_recursive(@path)
    end

    def app_routes
      app_routes_as_hash if @@routes.empty?
      @@routes
    end

    def verifiable_routes_list
      routes_table, list = @current_controller.instance_variable_get(:@_routes_table), []
        
      unless routes_table.nil?
        list = available_routes_list if routes_table[:all]
        list = routes_table[:only] unless routes_table[:only].nil?
        list = available_routes_list - routes_table[:except] unless routes_table[:except].nil?
      end

      list
    end

    def non_verifiable_routes_list
      routes_table, list = @current_controller.instance_variable_get(:@_routes_table), []

      unless routes_table.nil?
        unless routes_table[:skip].nil?
          list = routes_table[:skip].first == 'all' ? available_routes_list : routes_table[:skip]
        end
      end

      list
    end

    private

    def available_routes_list
      available_routes = self.app_routes[@current_controller.to_s.gsub(/Controller/, '')]
      # available_routes = self.action_methods if available_routes.nil?
      raise NoWayToDetectAvailableRoutesException if available_routes.nil?
      available_routes.to_set
    end

    # All controller classes placed in :default scope
    def app_controllers_recursive(path)
      invalid_entries = ['..', '.', 'concerns']
      (Dir.entries(path) - invalid_entries).each do |entry|
        if File.directory?(path + entry)
          app_controllers_recursive(path + entry + '/')
        else
          if File.extname(entry) == '.rb'
            parent_directory = File.dirname(path + entry).split(/\//).last
            container = parent_directory == 'controllers' ? 'default' : parent_directory
            @controllers[container.to_sym] ||= []
            @controllers[container.to_sym] << File.basename(path + entry, '.*') unless File.basename(path + entry, '.*') == 'application_controller'
          end
        end
      end
      @controllers
    end

    # Routes from routes.rb
    def app_routes_as_hash
      Rails.application.routes.routes.each do |route|
        controller = route.defaults[:controller]
        unless controller.nil?
          key = controller.split('/').map { |p| p.camelize }.join('::')
          @@routes[key] ||= []
          @@routes[key] << route.defaults[:action]
        end
      end
    end
  end
end

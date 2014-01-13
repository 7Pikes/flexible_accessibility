module FlexibleAccessibility
  class Utils
    @@routes ||= {}

    def initialize
      @path = "#{::Rails.root}/app/controllers/"
      @controllers = {}
    end

    def app_controllers
      app_controllers_recursive(@path)
    end

    def app_routes
      app_routes_as_hash if @@routes.empty?
      @@routes
    end

    private
    # All controller classes placed in :default scope
    def app_controllers_recursive(path)
      (Dir.new(path).entries - ['..', '.']).each do |entry|
        if File.directory?(path + entry)
          app_controllers_recursive(path + entry + '/')
        else
          parent_directory = File.dirname(path + entry).split(/\//).last
          container = parent_directory == 'controllers' ? 'default' : parent_directory
          @controllers[container.to_sym] = [] unless @controllers.has_key? container.to_sym
          @controllers[container.to_sym] << File.basename(path + entry, '.*') unless File.basename(path + entry, '.*') == 'application_controller'
        end
      end
      @controllers
    end

    # Routes from routes.rb
    def app_routes_as_hash
      Rails.application.routes.routes.each do |route|
        controller = route.defaults[:controller]
        unless controller.nil?
          key = controller.split('/').map { |p| p.camelize }.join('::').to_sym
          @@routes[key] ||= []
          @@routes[key] << route.defaults[:action]
        end
      end
    end
  end
end

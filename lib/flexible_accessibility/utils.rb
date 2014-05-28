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
      (Dir.entries(path) - excluded_controllers).each do |entry|
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

    def excluded_controllers
      ['..', '.', 'concerns']
    end
  end
end

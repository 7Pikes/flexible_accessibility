module FlexibleAccessibility
  class Utils
    def initialize
      @path = "#{::Rails.root}/app/controllers/"
      @controllers = {}
    end

    def get_controllers
      get_controllers_recursive(@path)
    end

    # All controller clases placed in :default scope
    def get_controllers_recursive(path)
      (Dir.new(path).entries - ["..", "."]).each do |entry|
        if File.directory?(path + entry)
          get_controllers_recursive(path + entry + '/')
        else
          parent_directory = File.dirname(path + entry).split(/\//).last
          container = parent_directory == "controllers" ? "default" : parent_directory
          @controllers[container.to_sym] = [] unless @controllers.has_key? container.to_sym
          @controllers[container.to_sym] << File.basename(path + entry, ".*") unless File.basename(path + entry, ".*") == "application_controller"
        end
      end
      @controllers
    end
  end
end

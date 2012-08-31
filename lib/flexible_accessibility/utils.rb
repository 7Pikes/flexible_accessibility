module FlexibleAccessibility
  class Utils
    def initialize
      @path = "#{::Rails.root}/app/controllers/"
      @controllers = {}
    end

    def get_controllers
      get_controllers_recursive @path
    end

    def get_controllers_recursive path
      (Dir.new(path).entries - ["..", "."]).each do |entry|
        if File.directory? path + entry
          get_controllers_recursive path + entry + '/'
        else
          parent_directory = File.dirname(path + entry).split(/\//).last
          puts parent_directory
          container = parent_directory == "controllers" ? "default" : parent_directory
          @controllers[container.to_sym] << File.basename(path + entry, ".*") unless File.basename(path + entry, ".*") == "application_controller"
        end
      end
      @controllers
    end
  end
end

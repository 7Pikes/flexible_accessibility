module FlexibleAccessibility
  class Utils
    def initialize
      @path = "#{::Rails.root}/app/controllers/"
      @controllers = []
    end

    def get_controllers
      get_controllers_recursive @path
    end

    def get_controllers_recursive path
      (Dir.new(path).entries - ["..", "."]).each do |entry|
        if File.directory? path + entry
          # TODO: Add namespace handling here
          # get_controllers_recursive path + entry + '/'
          next
        else
          @controllers << File.basename(path + entry, ".*") unless File.basename(path + entry, ".*") == "application_controller"
        end
      end
      @controllers
    end
  end
end
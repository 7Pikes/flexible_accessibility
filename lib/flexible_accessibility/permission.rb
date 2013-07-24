module FlexibleAccessibility
  class Permission
    attr_reader :resource
    attr_reader :actions
    attr_reader :permissions

    def initialize args={}
      @resource = args[:resource]
      @actions = args[:actions]
      @permissions = AccessRule.where(user_id: args[:current_user].id).to_a.map(&:permission) || []
    end

    def controller
    	ApplicationResource.new(self.resource).controller
    end

    def namespace
    	ApplicationResource.new(self.resource).namespace
    end

		# TODO: this function may be recursive because nesting may be existed
	  def self.all
			permissions = []
			Utils.new.get_controllers.each do |scope|
				namespace = scope.first.to_s
			  scope.last.each do |resource|
			  	resource = "#{namespace}/#{resource}" unless namespace == "default"
			  	permissions << Permission.new(:resource => resource.gsub(/_controller/, ""), :actions => ApplicationResource.new(resource).klass.instance_variable_get(:@_checkable_routes))
			  end
			end
			permissions
  	end

	  def is_action_permitted? permission
	  	permissions.include?(permission)
	  end
  end
end

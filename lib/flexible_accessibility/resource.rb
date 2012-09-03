module FlexibleAccessibility
	class ApplicationResource
		attr_reader :class
		attr_reader :namespace

	  def initialize resource_string
	  	@class = resource_string.split("::").last
	  	@namespace = resource_string.split("::").first
	  end

		def klass
			(@namespace.camelize + "::" + @class.camelize).constantize
		end
  end
end
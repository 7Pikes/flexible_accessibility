class Permission < ActiveRecord::Base

  class << self
		def get_permissions
		  permissions = {}
		  ApplicationController.subclasses.each do |klass|
			  permissions[klass.to_s.tableize.singularize.to_sym] = klass.constantize.action_methods.collect{ |a| a.to_s }.join(', ')
		  end
	  end

	  def check_access action, user
	  	!self.where(["action = ? and user_id = ?", action, user.id]).empty?
	  end
	end
end
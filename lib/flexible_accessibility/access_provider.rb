module FlexibleAccessibility
  class AccessProvider
    class << self
      def preload_permissions(user)
        if user.instance_variable_get(:@_available_permissions).nil?
          user.instance_variable_set(:@_available_permissions, AccessRule.where(:owner => user.id).map(&:permission))
        end
      end

      def is_action_permitted_for_user?(permission, user)
        preload_permissions(user)
        user.instance_variable_get(:@_available_permissions).include? permission
      end
    end
  end
end

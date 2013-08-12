module FlexibleAccessibility
  class AccessProvider
    class << self
      def preload_permissions user
        raise NoWayToLoadPermissionsException unless user.respond_to? :available_permissions=
        logged_user.available_permissions = AccessRule.where(:owner => user.id).map(&:permission)
      end

      def is_action_permitted_for_user? permission, user
        user.available_permissions.include? permission
      end
    end
  end
end

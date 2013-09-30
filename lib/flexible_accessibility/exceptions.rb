module FlexibleAccessibility
  class FlexibleAccessibilityException < StandardError
    attr_reader :action, :subject, :default_message

    def initialize(action = nil, subject = nil)
      @action = action
      @subject = subject
    end

    def to_s
      message || default_message
    end

    private
    def message
      nil
    end

    def default_message
      "An exception is occured"
    end
  end

	class AccessDeniedException < FlexibleAccessibilityException
    private
    def message
      I18n.t('flexible_accessibility.errors.access_denied', :action => @action)
    end

    def default_message
		  "The acess for resoure #{@action} is denied"
    end
	end

  class UserNotLoggedInException < FlexibleAccessibilityException
    private
    def message
      I18n.t('flexible_accessibility.errors.user_is_not_logged_in')
    end

    def default_message
      "Current user is not logged in"
    end
  end

  class NoWayToDetectLoggerUserException < FlexibleAccessibilityException
    private
    def message
      I18n.t('flexible_accessibility.errors.no_way_to_detect_logged_user')
    end

    def default_message
      "No way to detect a logged user - may you have forgot to define a current_user helper"
    end
  end
 
  class UnknownUserException < FlexibleAccessibilityException
    private
    def message
      I18n.t('flexible_accessibility.errors.unknown_user')
    end

    def default_message
      "Probably you have forgot to send a user in has_access?"
    end
  end

  class ActionsValueException < FlexibleAccessibilityException
    private
    def message
      I18n.t('flexible_accessibility.errors.incorrect_value_of_actions')
    end

    def default_message
      "The value of any 'authorize' macro argument should be declared as Array"
    end
  end
end

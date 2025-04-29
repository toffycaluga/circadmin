module CircusUsersHelper
    def role_label(role)
        I18n.t("roles.#{role}")
    end
end

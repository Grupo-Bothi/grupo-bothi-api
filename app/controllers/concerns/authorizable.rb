module Authorizable
  extend ActiveSupport::Concern

  private

  def require_super_admin!
    raise ApiErrors::ForbiddenError.new(message: I18n.t("auth.not_authorized")) unless current_user&.super_admin?
  end
end

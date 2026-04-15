class ApplicationController < ActionController::API
  include ErrorHandler
  include Authenticable
  include Pagy::Backend
  include PaginationConcern

  before_action :set_locale
  before_action :authenticate_request, unless: :authentication_controller?

  private

  def set_locale
    header = request.env["HTTP_ACCEPT_LANGUAGE"]
    lang   = header&.split(",")&.first&.split("-")&.first&.downcase&.to_sym
    I18n.locale = I18n.available_locales.include?(lang) ? lang : I18n.default_locale
  end

  def authentication_controller?
    self.class.module_parent == Api::V1 &&
    self.class.name.demodulize == "AuthenticationController"
  end
end

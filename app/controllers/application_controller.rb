class ApplicationController < ActionController::API
  include ErrorHandler
  include Authenticable
  include Pagy::Backend
  include PaginationConcern

  before_action :set_locale
  before_action :authenticate_request, unless: :authentication_controller?

  private

  def set_locale
    header = request.env["HTTP_LOCALE"] || request.env["HTTP_ACCEPT_LANGUAGE"]
    lang   = header&.split(",")
                   &.map { |l| l.split(";").first.split("-").first.strip.downcase.to_sym }
                   &.find { |l| I18n.available_locales.include?(l) }
    I18n.locale = lang || I18n.default_locale
  end

  def authentication_controller?
    self.class.module_parent == Api::V1 &&
    self.class.name.demodulize == "AuthenticationController"
  end
end

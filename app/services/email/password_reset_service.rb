# app/services/email/password_reset_service.rb
module Email
  class PasswordResetService
    include ActiveModel::Validations
    include JwtHelper

    attr_reader :user, :reset_url

    DEFAULT_EXPIRATION = 24.hours

    def initialize(user)
      @user = user
      validate_user!
    end

    def call
      generate_token
      build_reset_url

      Rails.logger.info "[PasswordReset] Generated reset URL: #{@reset_url}"

      response = send_email

      if email_sent_successfully?(response)
        log_success(response)
        { success: true, reset_url: @reset_url }
      else
        handle_email_failure(response)
      end
    rescue => e
      log_error(e)
      { success: false, error: e.message }
    end

    private

    def validate_user!
      raise ArgumentError, "User must be present" unless @user.present?
      raise ArgumentError, "User must be persisted" unless @user.persisted?
      raise ArgumentError, "User email must be present" unless @user.email.present?
    end

    def generate_token
      @token = jwt_encode(
        user_id: @user.id,
        email: @user.email,
        full_name: @user.full_name,
        exp: DEFAULT_EXPIRATION.from_now.to_i,
      )
    end

    def build_reset_url
      frontend_url = Rails.application.credentials.dig(:frontend_url) || ENV.fetch("FRONTEND_URL")
      @reset_url = URI.join(frontend_url, "/password?message=#{CGI.escape(@token)}").to_s
    end

    def send_email
      ResendMailer.password_reset(
        user: @user,
        reset_url: @reset_url,
        company_name: @user.companies.first&.name,
      )
    end

    def email_sent_successfully?(response)
      response.is_a?(Hash) && response["id"].present?
    end

    def log_success(response)
      Rails.logger.info "[PasswordReset] Email sent to #{@user.email}. Response: #{response.inspect}"
    end

    def handle_email_failure(response)
      error_message = "Failed to send email. Response: #{response.inspect}"
      Rails.logger.error "[PasswordReset] #{error_message}"
      { success: false, error: error_message }
    end

    def log_error(error)
      Rails.logger.error "[PasswordReset] Error: #{error.message}\n#{error.backtrace.join("\n")}"
    end
  end
end

module Email
  class SetPasswordService
    include JwtHelper

    TOKEN_EXPIRATION = 72.hours

    def initialize(user, company_name: nil)
      @user = user
      @company_name = company_name
    end

    def call
      generate_token
      build_set_password_url

      response = ResendMailer.set_password(user: @user, set_password_url: @set_password_url, company_name: @company_name)

      if email_sent_successfully?(response)
        Rails.logger.info "[SetPassword] Email sent to #{@user.email}"
        { success: true }
      else
        error_message = "Failed to send email. Response: #{response.inspect}"
        Rails.logger.error "[SetPassword] #{error_message}"
        { success: false, error: error_message }
      end
    rescue => e
      Rails.logger.error "[SetPassword] Error: #{e.message}\n#{e.backtrace&.first(5)&.join("\n")}"
      { success: false, error: e.message }
    end

    private

    def generate_token
      @token = jwt_encode(
        user_id:   @user.id,
        email:     @user.email,
        full_name: @user.full_name,
        exp:       TOKEN_EXPIRATION.from_now.to_i
      )
    end

    def build_set_password_url
      frontend_url = ENV.fetch("FRONTEND_URL", "http://localhost:4200")
      @set_password_url = "#{frontend_url}/set-password?token=#{CGI.escape(@token)}"
    end

    def email_sent_successfully?(response)
      response.is_a?(Hash) && response["id"].present?
    end
  end
end

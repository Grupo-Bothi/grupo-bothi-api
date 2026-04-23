module Api::V1
  class UsersController < BaseController
    before_action :set_user, only: [:show, :update, :destroy, :update_active, :active]

    # GET /api/v1/users
    def index
      users = User.includes(:companies)
        .non_employees
        .by_email(params[:email])
        .by_role(params[:role])
        .search(params[:search] || params[:text])
        .excluding_system_emails

      users = apply_sort(users, allowed: %i[first_name email role created_at], default: :created_at, default_dir: :desc)
      @pagy, @users = pagy(users)
      serialized = ActiveModelSerializers::SerializableResource.new(@users).as_json
      render json: paginate_response(@pagy, serialized)
    end

    # GET /api/v1/users/1
    def show
      render json: @user
    end

    # POST /api/v1/users
    def create
      attrs = user_create_params
      attrs[:password] = SecureRandom.hex(12) if attrs[:password].blank?

      @user = User.new(attrs)
      if @user.save
        send_set_password_email(@user)
        render json: UserSerializer.new(@user).serializable_hash, status: :created
      else
        render_error_response
      end
    end

    # PATCH/PUT /api/v1/users/1
    def update
      raise ApiErrors::UnprocessableEntityError.new(details: @user.errors) unless @user.update(user_update_params)
      render json: @user
    end

    # PATCH /api/v1/users/1/update_active  or  PATCH /api/v1/users/1/active
    def update_active
      @user.update!(active: !@user.active?)
      render json: @user
    end
    alias_method :active, :update_active

    # DELETE /api/v1/users/1
    def destroy
      @user.destroy!
      render json: { message: I18n.t("users.deleted") }
    end

    private

    def set_user
      @user = User.find(params[:id])
    rescue ActiveRecord::RecordNotFound
      raise ApiErrors::NotFoundError.new(message: I18n.t("users.not_found"))
    end

    def send_set_password_email(user)
      company_name = user.companies.pluck(:name).join(", ").presence
      Email::SetPasswordService.new(user, company_name: company_name).call
    rescue => e
      Rails.logger.error "[UsersController] SetPasswordService error class=#{e.class} message=#{e.message}"
    end

    def render_error_response
      error = ApiErrors::UnprocessableEntityError.new(details: @user.errors)
      render json: error.as_json, status: error.status
    end

    def user_create_params
      permitted = %i[first_name middle_name last_name second_last_name email phone]
      permitted += [:role, :password, :active, company_ids: []] if current_user.role.in?(%w[admin owner super_admin])
      params.require(:user).permit(*permitted)
    rescue ActionController::ParameterMissing => e
      raise ApiErrors::BadRequestError.new(message: e.message)
    end

    def user_update_params
      permitted = %i[first_name middle_name last_name second_last_name phone password]
      permitted += [:role, :active, company_ids: []] if current_user.role.in?(%w[admin owner super_admin])
      params.require(:user).permit(*permitted)
    rescue ActionController::ParameterMissing => e
      raise ApiErrors::BadRequestError.new(message: e.message)
    end
  end
end

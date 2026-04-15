# app/controllers/api/v1/employees_controller.rb
module Api
  module V1
    class EmployeesController < BaseController
      before_action :set_employee, only: [:show, :update, :destroy, :checkin, :checkout]

      def index
        employees = current_company.employees.includes(:user).search(params[:search])
        employees = employees.where(status: params[:status]) if params[:status].present?
        employees = apply_sort(employees, allowed: %i[name position department salary created_at], default: :name)
        @pagy, @employees = pagy(employees)
        serialized = ActiveModelSerializers::SerializableResource.new(@employees).as_json
        render json: paginate_response(@pagy, serialized)
      end

      def show
        render json: @employee
      end

      def create
        ActiveRecord::Base.transaction do
          email = params.dig(:employee, :email)
          phone = params.dig(:employee, :phone)
          employee = current_company.employees.build(employee_params.except(:email, :phone))
          temp_password = nil

          if email.present?
            temp_password = 'Pass123'
            user = User.create!(
              **employee.parsed_name_parts,
              email:    email,
              phone:    phone.to_s,
              password: temp_password,
              role:     :staff,
              active:   true
            )
            employee.user  = user
            employee.email = email
            employee.phone = phone
            current_company.user_companies.find_or_create_by!(user: user)
          end

          employee.save!

          response_data = ActiveModelSerializers::SerializableResource.new(employee).as_json
          response_data[:temp_password] = temp_password if temp_password
          render json: response_data, status: :created
        end
      end

      def update
        @employee.update!(employee_params.except(:email, :phone))
        render json: @employee
      end

      def destroy
        @employee.update!(status: :inactive)
        render json: { message: I18n.t("employees.deactivated") }
      end

      def checkin
        open = @employee.attendances.where(checkout_at: nil).exists?
        if open
          return render json: { error: I18n.t("employees.checkin_open") },
                        status: :unprocessable_entity
        end

        attendance = @employee.attendances.create!(
          company:         current_company,
          checkin_at:      Time.current,
          lat:             params[:lat],
          lng:             params[:lng],
          attendance_type: :normal
        )
        render json: attendance, status: :created
      end

      def checkout
        attendance = @employee.attendances
                              .where(checkout_at: nil)
                              .order(checkin_at: :desc)
                              .first

        if attendance.nil?
          return render json: { error: I18n.t("employees.no_checkin") },
                        status: :unprocessable_entity
        end

        attendance.update!(checkout_at: Time.current)
        render json: attendance
      end

      private

      def set_employee
        @employee = current_company.employees.includes(:user).find(params[:id])
      end

      def employee_params
        params.require(:employee).permit(:name, :position, :department, :salary, :status, :email, :phone)
      end
    end
  end
end

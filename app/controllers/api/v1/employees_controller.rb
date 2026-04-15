# app/controllers/api/v1/employees_controller.rb
module Api
  module V1
    class EmployeesController < BaseController
      before_action :set_employee, only: [:show, :update, :destroy, :checkin, :checkout]

      def index
        employees = current_company.employees.search(params[:search])
        employees = apply_sort(employees, allowed: %i[name position department salary created_at], default: :name)
        @pagy, @employees = pagy(employees)
        render json: paginate_response(@pagy, @employees)
      end

      def show
        render json: @employee
      end

      def create
        employee = current_company.employees.create!(employee_params)
        render json: employee, status: :created
      end

      def update
        @employee.update!(employee_params)
        render json: @employee
      end

      def destroy
        @employee.update!(status: :inactive)
        render json: { message: I18n.t("employees.deactivated") }
      end

      def checkin
        # Verifica que no tenga checkin abierto
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
        @employee = current_company.employees.find(params[:id])
      end

      def employee_params
        params.require(:employee).permit(:name, :position, :department, :salary, :status)
      end
    end
  end
end
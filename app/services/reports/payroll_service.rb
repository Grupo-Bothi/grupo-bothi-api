module Reports
  class PayrollService
    def initialize(company, range)
      @company = company
      @range   = range
    end

    def call
      employees = @company.employees.where(status: :active).order(:name)

      {
        period:        { from: @range.first, to: @range.last },
        total_payroll: employees.sum("COALESCE(salary, 0)").to_f,
        headcount:     employees.count,
        employees:     employees.map { |e| employee_data(e) }
      }
    end

    private

    def employee_data(employee)
      attendances  = employee.attendances.where(checkin_at: @range)
      type_counts  = attendances.group(:attendance_type).count
      hours_worked = attendances.where.not(checkout_at: nil)
                                .sum("EXTRACT(EPOCH FROM (checkout_at - checkin_at)) / 3600")
                                .to_f

      {
        id:           employee.id,
        name:         employee.name,
        position:     employee.position,
        department:   employee.department,
        salary:       employee.salary.to_f,
        days_present: attendances.count,
        hours_worked: hours_worked.round(2),
        attendance:   {
          normal: type_counts["normal"].to_i,
          late:   type_counts["late"].to_i,
          absent: type_counts["absent"].to_i
        }
      }
    end
  end
end

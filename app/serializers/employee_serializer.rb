# app/serializers/employee_serializer.rb
class EmployeeSerializer
  def initialize(employee)
    @employee = employee
  end

  def as_json(*)
    {
      id:         @employee.id,
      name:       @employee.name,
      position:   @employee.position,
      department: @employee.department,
      salary:     @employee.salary,
      status:     @employee.status,
      created_at: @employee.created_at
    }
  end
end
class MakeWorkOrderEmployeeOptional < ActiveRecord::Migration[8.0]
  def change
    change_column_null :work_orders, :employee_id, true
  end
end

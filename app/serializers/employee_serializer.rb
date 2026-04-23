# app/serializers/employee_serializer.rb
class EmployeeSerializer < ActiveModel::Serializer
  attributes :id, :name, :email, :phone, :position, :department, :salary, :status,
             :created_at, :updated_at

  attribute :user do
    next nil unless object.user
    
    {
      id:     object.user.id,
      email:  object.user.email,
      role:   object.user.role,
      active: object.user.active
    }
  end
end

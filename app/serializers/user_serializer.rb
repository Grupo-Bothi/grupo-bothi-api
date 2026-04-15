class UserSerializer < ActiveModel::Serializer
  attributes :id, :first_name, :middle_name, :last_name, :second_last_name,
             :email, :phone, :role, :active, :created_at, :updated_at

  has_many :companies, serializer: CompanySerializer
end

class UserSerializer < ActiveModel::Serializer
  include Rails.application.routes.url_helpers

  attributes :id, :first_name, :middle_name, :last_name, :second_last_name,
             :email, :phone, :role, :active, :description, :avatar_url,
             :created_at, :updated_at

  has_many :companies, serializer: CompanySerializer

  def avatar_url
    return nil unless object.avatar.attached?

    url_for(object.avatar)
  end
end

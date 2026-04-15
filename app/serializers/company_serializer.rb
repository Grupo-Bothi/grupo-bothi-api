class CompanySerializer < ActiveModel::Serializer
  attributes :id, :name, :slug, :plan, :stripe_id, :created_at, :updated_at

  attribute :users_count do
    object.users.size
  end
end

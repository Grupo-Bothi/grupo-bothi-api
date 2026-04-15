# app/serializers/unit_serializer.rb
class UnitSerializer
  def initialize(unit)
    @unit = unit
  end

  def as_json(*)
    {
      id:       @unit.id,
      key:      @unit.key,
      name:     @unit.name,
      group:    @unit.group
    }
  end
end

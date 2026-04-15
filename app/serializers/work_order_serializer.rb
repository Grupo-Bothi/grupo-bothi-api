# app/serializers/work_order_serializer.rb
class WorkOrderSerializer
  def initialize(order, detailed: false)
    @order    = order
    @detailed = detailed
  end

  def as_json(*)
    base = {
      id:           @order.id,
      title:        @order.title,
      description:  @order.description,
      priority:     @order.priority,
      priority_label: I18n.t("work_order.priority.#{@order.priority}"),
      status:       @order.status,
      status_label: I18n.t("work_order.status.#{@order.status}"),
      due_date:     @order.due_date,
      completed_at: @order.completed_at,
      notes:        @order.notes,
      progress:     @order.progress,
      total:        @order.total,
      created_at:   @order.created_at,
      employee:     @order.employee ? {
        id:   @order.employee.id,
        name: @order.employee.name
      } : nil,
      items_count:  @order.work_order_items.size,
      items_done:   @order.work_order_items.where(status: :completed).count
    }

    if @detailed
      base[:items] = @order.work_order_items.map do |item|
        {
          id:           item.id,
          description:  item.description,
          quantity:     item.quantity,
          unit:         item.unit,
          unit_price:   item.unit_price,
          subtotal:     item.subtotal,
          status:       item.status,
          position:     item.position,
          completed_at: item.completed_at,
          product:      item.product ? {
            id:       item.product.id,
            sku:      item.product.sku,
            name:     item.product.name,
            category: item.product.category
          } : nil
        }
      end
    end

    base
  end
end

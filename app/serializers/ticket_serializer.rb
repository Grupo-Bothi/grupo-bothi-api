# app/serializers/ticket_serializer.rb
class TicketSerializer
  def initialize(ticket, detailed: false)
    @ticket   = ticket
    @detailed = detailed
  end

  def as_json(*)
    base = {
      id:           @ticket.id,
      folio:        @ticket.folio,
      status:       @ticket.status,
      status_label: I18n.t("ticket.status.#{@ticket.status}"),
      total:        @ticket.total,
      notes:        @ticket.notes,
      paid_at:      @ticket.paid_at,
      created_at:   @ticket.created_at,
      work_order: {
        id:       @ticket.work_order_id,
        title:    @ticket.work_order.title,
        priority: @ticket.work_order.priority,
        status:   @ticket.work_order.status
      }
    }

    if @detailed
      order = @ticket.work_order
      base[:items] = order.work_order_items.map do |item|
        {
          description: item.description,
          quantity:    item.quantity,
          unit:        item.unit,
          unit_price:  item.unit_price,
          subtotal:    item.subtotal
        }
      end
    end

    base
  end
end

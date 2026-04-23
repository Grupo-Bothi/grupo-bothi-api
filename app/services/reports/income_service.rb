module Reports
  class IncomeService
    def initialize(company, range, group_by)
      @company  = company
      @range    = range
      @group_by = group_by
    end

    def call
      tickets = @company.tickets.where(status: :paid, paid_at: @range).order(:paid_at)

      {
        period:        { from: @range.first, to: @range.last },
        total_revenue: tickets.sum(:total).to_f,
        total_tickets: tickets.count,
        by_period:     group_tickets(tickets),
        breakdown:     breakdown(tickets)
      }
    end

    private

    def group_tickets(tickets)
      tickets.group_by { |t| period_key(t.paid_at) }.map do |period, group|
        {
          period:  period,
          revenue: group.sum { |t| t.total.to_f },
          count:   group.size
        }
      end.sort_by { |g| g[:period] }
    end

    def breakdown(tickets)
      tickets.includes(work_order: :employee).map do |ticket|
        {
          id:         ticket.id,
          folio:      ticket.folio,
          total:      ticket.total.to_f,
          paid_at:    ticket.paid_at,
          work_order: {
            id:       ticket.work_order_id,
            title:    ticket.work_order.title,
            employee: ticket.work_order.employee&.name
          }
        }
      end
    end

    def period_key(datetime)
      case @group_by
      when "week"  then datetime.strftime("%Y-W%V")
      when "year"  then datetime.strftime("%Y")
      else              datetime.strftime("%Y-%m")
      end
    end
  end
end

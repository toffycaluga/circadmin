module TransactionSummaryHelper
  def transaction_summary_for(locality, period = :day)
    case period
    when :day
      last_date = locality.transactions.where(transaction_type: "income").maximum(:date)
      return nil unless last_date

      last_date = last_date.to_date
      range = last_date.all_day
      previous_range = (last_date - 1.day).all_day
    when :week
      range = 1.week.ago.beginning_of_week..Time.current
      previous_range = 2.weeks.ago.beginning_of_week..1.week.ago.end_of_week
    when :month
      range = 1.month.ago.beginning_of_month..Time.current
      previous_range = 2.months.ago.beginning_of_month..1.month.ago.end_of_month
    else
      return nil
    end

    todays = locality.transactions.where(date: range, transaction_type: "income")
    return nil if todays.empty?

    total = todays.sum(:amount)
    previous_total = locality.transactions.where(date: previous_range, transaction_type: "income").sum(:amount)
    change_percent = previous_total.zero? ? 0 : ((total - previous_total) / previous_total.to_f * 100).round(2)

    grouped = todays.group(:category).sum(:amount)

    {
      total: total,
      change_percent: change_percent,
      by_category: grouped
    }
  end
end

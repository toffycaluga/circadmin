class TransactionSummaryService
  def initialize(locality, period = :day)
    @locality = locality
    @period = period
  end

  def call
    case @period
    when :day
      last_date = @locality.transactions.where(transaction_type: "income").maximum(:date)
      return nil unless last_date

      last_date = last_date.to_date
      range = last_date.all_day
      previous_range = (last_date - 1.day).all_day
      target_date = last_date

      transactions = @locality.transactions.where(date: range, transaction_type: "income")
    when :week
      today = Time.zone.today
      range = today.beginning_of_week..today.end_of_day
      previous_range = (today - 1.week).beginning_of_week..(today - 1.week).end_of_week
      target_date = nil

      transactions = @locality.transactions.where(date: range, transaction_type: "income")
    when :month
      today = Time.zone.today
      range = today.beginning_of_month..today.end_of_day
      previous_range = (today - 1.month).beginning_of_month..(today - 1.month).end_of_month
      target_date = nil

      transactions = @locality.transactions.where(date: range, transaction_type: "income")
    when :all
      transactions = @locality.transactions.where(transaction_type: "income")
      return nil if transactions.empty?

      total = transactions.sum(:amount)
      grouped = transactions.group_by { |t| t.category.strip.downcase }
                            .transform_values { |ts| ts.sum(&:amount) }

      return {
        total: total,
        change_percent: 0,
        by_category: grouped,
        range: transactions.minimum(:date).to_date..transactions.maximum(:date).to_date,
        target_date: nil
      }
    else
      return nil
    end

    return nil if transactions.empty?

    total = transactions.sum(:amount)
    previous_total = @locality.transactions.where(date: previous_range, transaction_type: "income").sum(:amount)
    change_percent = previous_total.zero? ? 0 : ((total - previous_total) / previous_total.to_f * 100).round(2)

    grouped = transactions.group("LOWER(TRIM(category))").sum(:amount)


    {
      total: total,
      change_percent: change_percent,
      by_category: grouped,
      range: range,
      target_date: target_date
    }
  end
end

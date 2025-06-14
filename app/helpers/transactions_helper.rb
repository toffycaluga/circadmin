module TransactionsHelper
    def transaction_summary_for(locality, period = :day)
        case period
        when :day
        range = locality.transactions.order(date: :desc).pluck(:date).first&.to_date&.all_day
        when :week
        range = Time.zone.now.all_week
        when :month
        range = Time.zone.now.all_month
        else
        return {}
        end

        transactions = locality.transactions.where(date: range)

        incomes = transactions.where(transaction_type: "income").sum(:amount)
        expenses = transactions.where(transaction_type: "expense").sum(:amount)

        {
        from: range.first,
        to: range.last,
        incomes: incomes,
        expenses: expenses,
        balance: incomes - expenses,
        exists: transactions.exists?
        }
    end
    def formatted_label(label, group_type, locality)
        case group_type
        when "weekly"
            start_date = label.beginning_of_week.to_date
            end_date = label.end_of_week.to_date
            "#{l(start_date, format: :short)} — #{l(end_date, format: :short)}"
        when "monthly"
            l(label.to_date, format: "%B %Y")
        when "total"
            start = locality.start_date
            end_date = locality.end_date.present? ? l(locality.end_date, format: :long) : t("transactions.total.currently", default: "Actualmente")
            "#{l(start, format: :long)} — #{end_date}"
        else
            l(label.to_date, format: :long)
        end
    end
end

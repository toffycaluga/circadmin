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
end

class LocalitiesController < ApplicationController
  before_action :set_locality, only: %i[show edit update destroy]
  before_action :set_circus
  layout "dashboard"

  # GET /localities
  def index
    @localities = Locality.all
  end

  # GET /localities/1
  def show
    @locality = Locality.find(params[:id])
    @incomes  = @locality.transactions.incomes.order(date: :desc)
    @expenses = @locality.transactions.expenses.order(date: :desc)
  end

  def admin
    @locality = Locality.find(params[:id])
    @incomes  = @locality.transactions.where(transaction_type: "income")
    @expenses = @locality.transactions.where(transaction_type: "expense")
    @unread_notifications_count = current_user.notifications.unread.count

    @last_day_summary = TransactionSummaryService.new(@locality, :day).call
    @weekly_summary   = TransactionSummaryService.new(@locality, :week).call

    months_with_income = @incomes.pluck(:date).map(&:beginning_of_month).uniq
    @monthly_summary = if months_with_income.size > 1
      TransactionSummaryService.new(@locality, :month).call
    else
      nil
    end

    @overall_summary = TransactionSummaryService.new(@locality, :all).call
  end

  def insights
    @locality = Locality.find(params[:id])

    @start_date = params[:start_date]&.to_date || 1.month.ago.to_date
    @end_date   = params[:end_date]&.to_date   || Date.today

    transactions = @locality.transactions
                            .where(date: @start_date..@end_date, transaction_type: "income")

    @summary_by_category = transactions
      .group("LOWER(TRIM(category))")
      .sum(:amount)
      .sort_by { |_, amount| -amount }
      .to_h

    @transactions = transactions.order(date: :desc)
  end

  # para desactivar una localidad
  def deactivate
    @locality = Locality.find(params[:id])
    @locality.update(active: false)
    redirect_to admin_locality_path(@locality), notice: t("localities.notices.deactivated")
  end

  # para activar una plaza o evento
  def reactivate
    @locality = Locality.find(params[:id])
    @locality.update(active: true)
    redirect_to admin_locality_path(@locality), notice: t("localities.notices.reactivated")
  end

  def transaction_summary_for(locality, period = :day)
    case period
    when :day
      last_date = locality.transactions.where(transaction_type: "income").maximum(:date)&.to_date
      return nil unless last_date

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

    grouped = current_transactions.group_by { |t| t.category.strip.downcase }.transform_values { |ts| ts.sum(&:amount) }

    {
      total: total,
      change_percent: change_percent,
      by_category: grouped,
      range: range
    }
  end

  # controlador de resumenes
  def summary
    @locality = Locality.find(params[:id])
    period = params[:period]&.to_sym || :day
    summary_service = TransactionSummaryService.new(@locality, period)
    @summary = summary_service.call

    if @summary.nil?
      redirect_to admin_locality_path(@locality), alert: t("localities.alerts.no_data")
    else
      @transactions = @locality.transactions
                                .where(date: @summary[:range], transaction_type: "income")
                                .order(date: :desc)
    end
  end

  # GET /localities/new
  def new
    @locality = Locality.new(circus: @circus)
  end

  # GET /localities/1/edit
  def edit; end

  # POST /localities
  def create
    @locality = Locality.new(locality_params)
    @circus = Circus.find(@locality.circus_id)

    respond_to do |format|
      if @locality.save
        format.html do
          redirect_to admin_circus_path(@circus),
                      notice: t("localities.notices.created", default: "La localidad fue creada con éxito.")
        end
        format.json { render :show, status: :created, location: @locality }
      else
        format.html { render :new, status: :unprocessable_entity }
        format.json { render json: @locality.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /localities/1
  def update
    respond_to do |format|
      if @locality.update(locality_params)
        format.html do
          redirect_to admin_circus_path(@locality.circus),
                      notice: t("localities.notices.updated", default: "La localidad fue actualizada con éxito.")
        end
        format.json { render :show, status: :ok, location: @locality }
      else
        format.html { render :edit, status: :unprocessable_entity }
        format.json { render json: @locality.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /localities/1
  def destroy
    @circus = @locality.circus
    @locality.destroy!

    respond_to do |format|
      format.html do
        redirect_to admin_circus_path(@circus),
                    notice: t("localities.notices.destroyed", default: "La localidad fue eliminada.")
      end
      format.json { head :no_content }
    end
  end

  private

  def set_locality
    @locality = Locality.find(params.fetch(:id))
  end

  def set_circus
    circus_id = params[:circus_id] || params.dig(:locality, :circus_id)
    @circus = Circus.find(circus_id) if circus_id.present?
  end

  def locality_params
    params.require(:locality).permit(:title, :location, :city, :start_date, :end_date, :active, :circus_id)
  end
end

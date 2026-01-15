class TransactionsController < ApplicationController
  before_action :set_transaction, only: %i[show edit update destroy card]
  layout "dashboard"

  # Vista index (opcional, si la usas como historial general)
  def index
    @transactions = current_circus.transactions.order(date: :desc)
  end

  # Mostrar detalles individuales (no es usado en resumen/exportación)
  def show; end

  # =============== VISTA DE RESUMEN DETALLADO (en pantalla) ===============
  def summary_details
    @locality   = Locality.find(params[:id])
    @group_type = params[:group]
    @type       = params[:type]
    @label      = parse_label(params[:date], @group_type) # genera un Date base desde el string

    scope = @type == "income" ? @locality.transactions.incomes : @locality.transactions.expenses

    @transactions = case @group_type
    when "daily"
                      scope.where(date: @label)
    when "weekly"
                      first_date = scope.minimum(:date)
                      first_date ? scope.where(date: @label.beginning_of_week..@label.end_of_week) : scope.none
    when "monthly"
                      scope.where(date: @label.beginning_of_month..@label.end_of_month)
    when "total"
                      scope
    else
                      scope.none
    end
  end

  # =============== EXPORTACIÓN PDF ===============
  def export_pdf
    @locality   = Locality.find(params[:locality_id])
    @type       = params[:type]
    @group_type = params[:group]
    @label      = parse_label(params[:label], @group_type)

    @transactions = filter_summary_transactions

    pdf = TransactionsPdf.new(@transactions, @locality, @type)
    send_data pdf.render,
              filename: "resumen_transacciones_#{Time.now.strftime('%Y%m%d')}.pdf",
              type: "application/pdf",
              disposition: "attachment"
  end

  # =============== EXPORTACIÓN EXCEL ===============
  def export_excel
    @locality   = Locality.find(params[:locality_id])
    @type       = params[:type]
    @group_type = params[:group]
    @label      = parse_label(params[:label], @group_type)

    @transactions = filter_summary_transactions

    respond_to do |format|
      format.xlsx do
        response.headers["Content-Disposition"] =
          "attachment; filename=resumen_transacciones_#{Time.now.strftime('%Y%m%d')}.xlsx"
      end
    end
  end

  # =============== PARSEO DE FECHAS PARA AGRUPACIONES ===============
  def parse_label(label, group_type)
    return Date.today if label.blank?

    case group_type
    when "monthly"
      Date.strptime(label.to_s, "%Y-%m") rescue Date.today
    when "weekly", "daily"
      Date.parse(label.to_s) rescue Date.today
    else
      Date.today
    end
  end

  # =============== USADO POR EXPORTADORES PARA FILTRAR DATOS ===============
  def filter_summary_transactions
    scope = @locality.transactions
    scope = scope.where(transaction_type: @type) if @type.present?

    case @group_type
    when "daily"
      scope.where(date: @label)
    when "weekly"
      scope.where(date: @label.beginning_of_week..@label.end_of_week)
    when "monthly"
      scope.where(date: @label.beginning_of_month..@label.end_of_month)
    when "total"
      scope
    else
      scope.none
    end
  end

  # =============== DASHBOARD DE AGRUPACIONES PRINCIPALES ===============
  def overview
    @locality   = Locality.find(params[:id])
    @group_type = params[:group] || "daily"
    @type       = params[:type]  || "income"
    @order      = params[:order] || "date"

    scope = Transaction.where(locality: @locality, transaction_type: @type)

    @summaries = case @group_type
    when "daily"
                   scope.group_by_day(:date).sum(:amount)
    when "weekly"
                   first_date = scope.minimum(:date)
                   first_date ? scope.group_by_week(:date, week_start: :monday, range: first_date.beginning_of_week..).sum(:amount) : {}
    when "monthly"
                   scope.group_by_month(:date).sum(:amount)
    else
                   { I18n.t("transactions.overview.total") => scope.sum(:amount) }
    end
  end

  # =============== FORMULARIOS Y CRUD ===============
  def new
    @transaction = Transaction.new(
      transaction_type: params[:transaction_type],
      locality_id:      params[:locality_id],
      date:             Time.current
    )
    @locality = Locality.find(params[:locality_id])
  end

  def edit; end

  def create
    @transaction        = Transaction.new(transaction_params)
    @transaction.user   = current_user
    @transaction.circus = current_circus

    if @transaction.save
      redirect_to admin_locality_path(@transaction.locality),
                  notice: t("flash.transactions.create.success")
    else
      flash.now[:alert] = t("flash.transactions.create.failure")
      render :new, status: :unprocessable_entity
    end
  end

  def update
    if @transaction.update(transaction_params)
      redirect_to locality_path(@transaction.locality),
                  notice: t("flash.transactions.update.success")
    else
      flash.now[:alert] = t("flash.transactions.update.failure")
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @transaction.destroy!
    flash[:notice] = t("flash.transactions.destroy.success")

    previous = (session[:history] && session[:history][1]) || transactions_path
    redirect_to previous, status: :see_other
  end

  def card
    @transaction = Transaction.find(params[:id])
  end

  # =============== PRIVATE HELPERS ===============
  private

  def set_transaction
    @transaction = Transaction.find(params[:id])
  end

  def transaction_params
    params.require(:transaction).permit(
      :title, :amount, :transaction_type, :category,
      :description, :date, :locality_id, :user_id, :circus_id, :receipt
    )
  end
end

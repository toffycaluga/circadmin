class TransactionsController < ApplicationController
  before_action :set_transaction, only: %i[ show edit update destroy card]
  layout "dashboard"

  # GET /transactions
  def index
    @transactions = current_circus.transactions.order(date: :desc)
  end

  # GET /transactions/1
  def show
  end

  def summary_details
    @locality = Locality.find(params[:id])
    @group_type = params[:group]
    @type = params[:type]
    @label = parse_label(params[:date], @group_type)

    scope = @type == "income" ? @locality.transactions.incomes : @locality.transactions.expenses

    @transactions = case @group_type
    when "daily"
      scope.where(date: @label)

    when "weekly"
      first_date = scope.minimum(:date)

      if first_date
        start_date = @label.beginning_of_week
        end_date = @label.end_of_week
        scope.where(date: start_date..end_date)
      else
        scope.none
      end

    when "monthly"
      scope.where(date: @label.beginning_of_month..@label.end_of_month)

    when "total"
      scope

    else
      scope.none
    end
  end

  def card
    puts "✅ Entrando a la acción 'card'"
    @transaction = Transaction.find(params[:id])
    # render plain: "Transacción: #{@transaction.title}"
  end




  def parse_label(label, group_type)
    return Date.today if label.blank?

    case group_type
    when "monthly"
      begin
        # si es string tipo "2025-06", se parsea bien
        Date.strptime(label.to_s, "%Y-%m")
      rescue
        Date.today
      end
    when "weekly", "daily"
      Date.parse(label.to_s) rescue Date.today
    else
      Date.today
    end
  end


  # controlador para ver los detalles

  def overview
    @locality = Locality.find(params[:id])
    @group_type = params[:group] || "daily"
    @type = params[:type] || "income"
    @order = params[:order] || "date"

    scope = Transaction.where(locality: @locality, transaction_type: @type)

    @summaries = case @group_type
    when "daily"
      scope.group_by_day(:date).sum(:amount)

    when "weekly"
      first_date = scope.minimum(:date)
      if first_date
        scope.group_by_week(:date, week_start: :monday, range: first_date.beginning_of_week..) .sum(:amount)
      else
        {}
      end

    when "monthly"
      scope.group_by_month(:date).sum(:amount)

    else
      { "Total" => scope.sum(:amount) }
    end
  end


  # GET /transactions/new
  def new
    puts "Tipo recibido: #{params[:transaction_type]}"
    @transaction = Transaction.new(
      transaction_type: params[:transaction_type],
      locality_id: params[:locality_id],
      date: Time.current
    )
    @locality=Locality.find(params[:locality_id])
  end


  # GET /transactions/1/edit
  def edit
  end

  # POST /transactions
  def create
    @transaction = Transaction.new(transaction_params)
    @transaction.user = current_user
    @transaction.circus = current_circus

    if @transaction.save
      redirect_to admin_locality_path(@transaction.locality), notice: "Transacción registrada correctamente."
    else
      render :new, status: :unprocessable_entity
    end
  end

  # PATCH/PUT /transactions/1
  def update
    if @transaction.update(transaction_params)
      redirect_to locality_path(@transaction.locality), notice: "Transacción actualizada correctamente."
    else
      render :edit, status: :unprocessable_entity
    end
  end

  # DELETE /transactions/1
  def destroy
    @transaction.destroy!
    redirect_to transactions_path, status: :see_other, notice: "Transacción eliminada correctamente."
  end

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

class TransactionsController < ApplicationController
  before_action :set_transaction, only: %i[ show edit update destroy ]
  layout "dashboard"

  # GET /transactions
  def index
    @transactions = current_circus.transactions.order(date: :desc)
  end

  # GET /transactions/1
  def show
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

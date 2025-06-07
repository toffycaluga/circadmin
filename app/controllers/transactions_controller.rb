class TransactionsController < ApplicationController
  before_action :set_transaction, only: %i[ show edit update destroy ]
  layout "dashboard"
  # GET /transactions or /transactions.json
  def index
    @transactions = current_circus.transactions.order(date: :desc)
  end


  # GET /transactions/1 or /transactions/1.json
  def show
  end

  # GET /transactions/new
  def new
    @transaction = Transaction.new
  end

  # GET /transactions/1/edit
  def edit
  end

  # POST /transactions or /transactions.json
  def create
    @transaction = Transaction.new(transaction_params)
    @transaction.user = current_user
    @transaction.circus = current_circus

    if @transaction.save
      redirect_to @transaction, notice: "Transacción registrada correctamente."
    else
      render :new, status: :unprocessable_entity
    end
  end


  # PATCH/PUT /transactions/1 or /transactions/1.json
  def update
    respond_to do |format|
      if @transaction.update(transaction_params)
        format.html { redirect_to @transaction, notice: "Transaction was successfully updated." }
        format.json { render :show, status: :ok, location: @transaction }
      else
        format.html { render :edit, status: :unprocessable_entity }
        format.json { render json: @transaction.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /transactions/1 or /transactions/1.json
  def destroy
    @transaction.destroy!

    respond_to do |format|
      format.html { redirect_to transactions_path, status: :see_other, notice: "Transaction was successfully destroyed." }
      format.json { head :no_content }
    end
  end

  def transaction_params
    params.require(:transaction).permit(
      :title, :amount, :transaction_type, :description,
      :date, :circus_id, :user_id, :receipt
    )
  end


  private
    # Use callbacks to share common setup or constraints between actions.
    def set_transaction
      @transaction = Transaction.find(params.expect(:id))
    end

    # Only allow a list of trusted parameters through.
    def transaction_params
      params.expect(transaction: [ :title, :amount, :transaction_type, :description, :date, :user_id, :circus_id ])
    end
end

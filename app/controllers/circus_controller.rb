class CircusController < ApplicationController
  before_action :set_circu, only: %i[ show edit update destroy ]

  # GET /circus or /circus.json
  def index
    @circus = Circu.all
  end

  # GET /circus/1 or /circus/1.json
  def show
  end

  # GET /circus/new
  def new
    @circu = Circu.new
  end

  # GET /circus/1/edit
  def edit
  end

  # POST /circus or /circus.json
  def create
    @circu = Circu.new(circu_params)

    respond_to do |format|
      if @circu.save
        format.html { redirect_to @circu, notice: "Circu was successfully created." }
        format.json { render :show, status: :created, location: @circu }
      else
        format.html { render :new, status: :unprocessable_entity }
        format.json { render json: @circu.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /circus/1 or /circus/1.json
  def update
    respond_to do |format|
      if @circu.update(circu_params)
        format.html { redirect_to @circu, notice: "Circu was successfully updated." }
        format.json { render :show, status: :ok, location: @circu }
      else
        format.html { render :edit, status: :unprocessable_entity }
        format.json { render json: @circu.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /circus/1 or /circus/1.json
  def destroy
    @circu.destroy!

    respond_to do |format|
      format.html { redirect_to circus_path, status: :see_other, notice: "Circu was successfully destroyed." }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_circu
      @circu = Circu.find(params.expect(:id))
    end

    # Only allow a list of trusted parameters through.
    def circu_params
      params.expect(circu: [ :name, :description, :country, :currency, :active, :user_id ])
    end
end

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
    @incomes = @locality.transactions.incomes.order(date: :desc)
    @expenses = @locality.transactions.expenses.order(date: :desc)
  end
  def admin
    @locality = Locality.find(params[:id])
    @incomes = @locality.transactions.where(transaction_type: "income")
    @expenses = @locality.transactions.where(transaction_type: "expense")
  end
  # para desactivar una localidad
  def deactivate
    @locality = Locality.find(params[:id])
    @locality.update(active: false)
    redirect_to admin_locality_path(@locality), notice: "El evento ha sido marcado como cerrado."
  end
  # para ativar una plaza o evento
  def reactivate
    @locality = Locality.find(params[:id])
    @locality.update(active: true)
    redirect_to admin_locality_path(@locality), notice: "El evento ha sido reactivado."
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
    @circus = @locality.circus # ← aseguramos que no sea nil
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

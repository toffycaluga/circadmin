class CircusesController < ApplicationController
  layout "dashboard"
  before_action :authenticate_user!
  before_action :set_circus, only: %i[ show edit update destroy ]
  # GET /circuses
  def index
    @circuses = current_user.circuses
  end

  # GET /circuses/1
  def show
  end

  # GET /circuses/new
  def new
    @circus = current_user.circuses.build
  end

  # GET /circuses/1/edit
  def edit
  end

  # POST /circuses
  def create
    @circus = current_user.circuses.build(circus_params)

    respond_to do |format|
      if @circus.save
        format.html { redirect_to @circus, notice: "Circo creado con éxito." }
        format.json { render :show, status: :created, location: @circus }
      else
        format.html { render :new, status: :unprocessable_entity }
        format.json { render json: @circus.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /circuses/1
  def update
    respond_to do |format|
      if @circus.update(circus_params)
        format.html { redirect_to @circus, notice: "Circo actualizado con éxito." }
        format.json { render :show, status: :ok, location: @circus }
      else
        format.html { render :edit, status: :unprocessable_entity }
        format.json { render json: @circus.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /circuses/1
  def destroy
    @circus.destroy
    respond_to do |format|
      format.html { redirect_to circuses_path, notice: "Circo eliminado correctamente." }
      format.json { head :no_content }
    end
  end

  private

  def set_circus
    @circus = current_user.circuses.find(params[:id])
  end

  def circus_params
    params.require(:circus).permit(:name, :description, :country, :currency, :active, :logo)
  end
end

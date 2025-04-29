class CircusesController < ApplicationController
  layout "dashboard"
  before_action :authenticate_user!
  before_action :set_circus, only: %i[ show edit update destroy ]
  # GET /circuses
  def index
    @circuses = current_user.circuses
    @owned_circuses = current_user.owned_circuses
    @associated_circuses= current_user.associated_circuses
  end

  # GET /circuses/1
  def show
  end
  # app/controllers/circuses_controller.rb
  def admin
    @circus = current_user.circuses.find(params[:id])
  end


  # GET /circuses/new
  def new
    @circus = current_user.circuses.build
  end

  # GET /circuses/1/edit
  def edit
  end
  def admin
    @circus = current_user.circuses.find(params[:id])
    session[:current_circus_id] = @circus.id
  end

  # POST /circuses
  def create
    # @circus = current_user.circuses.build(circus_params)
    @circus = Circus.new(circus_params)
    @circus.user = current_user
    respond_to do |format|
      if @circus.save
        # 👇 Creamos el rol de dueño en la tabla intermedia
        CircusUser.create!(user: current_user, circus: @circus, role: "owner")

        format.html { redirect_to root_path, notice: "Circo creado con éxito." }
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

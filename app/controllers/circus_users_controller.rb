class CircusUsersController < ApplicationController
  # 1. Asegura que sólo usuarios autenticados puedan acceder
  before_action :authenticate_user!

  # 2. Carga el registro de CircusUser según el :id de la ruta
  before_action :set_circus_user

  # 3. Verifica que quien hace la petición sea OWNER de ese circo
  before_action :authorize_owner!

  # GET /circus_users/:id/edit
  # Muestra el formulario para cambiar el rol de @circus_user
  def edit
    # @circus_user ya está cargado por set_circus_user
  end

  # PATCH /circus_users/:id
  # Actualiza explícitamente sólo el atributo :role
  def update
    # 4. Extraemos el nuevo rol desde params — no usamos permit para basura
    new_role = params[:circus_user][:role]

    # 5. Validamos que new_role esté entre los roles permitidos
    if CircusUser::ROLES.include?(new_role)
      # 6. Intentamos actualizar sólo el campo :role
      if @circus_user.update(role: new_role)
        redirect_to admin_circus_path(@circus_user.circus), notice: t("cu_notice.update")
      else
        # En caso de fallo en validaciones de modelo
        render :edit, status: :unprocessable_entity
      end
    else
      # 7. Si alguien envía un rol que no existe
      redirect_to edit_circus_user_path(@circus_user), alert: "Rol inválido"
    end
  end

  # DELETE /circus_users/:id
  # En vez de borrar el registro, marcamos active: false
  def destroy
    @circus_user.update(active: false)
    redirect_to admin_circus_path(@circus_user.circus), notice: t("cu_notice.destroy")
  end

  # PATCH /circus_users/:id/deactivate
  # Acción dedicada a desactivación
  def deactivate
    @circus_user.update(active: false)
    redirect_to admin_circus_path(@circus_user.circus), notice: t("cu_notice.deactivate")
  end

  private

  # Carga @circus_user desde la DB
  def set_circus_user
    @circus_user = CircusUser.find(params[:id])
  end

  # Comprueba que current_user sea OWNER del circo de @circus_user
  def authorize_owner!
    unless current_user.owned_circuses.include?(@circus_user.circus)
      redirect_to root_path, alert: "No tienes permiso para realizar esta acción."
    end
  end

  # NOTA: ya no usamos strong params genéricos para :role,
  # porque hacemos la asignación manualmente para evitar
  # mass assignment de campos sensibles.
  # def circus_user_params
  #   params.require(:circus_user).permit(:role)
  # end
end

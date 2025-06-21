# app/controllers/documents_controller.rb
class DocumentsController < ApplicationController
  before_action :authenticate_user!
  layout "dashboard"
  include Pagy::Backend

  # Usa Cancancan para cargar y autorizar recursos automáticamente
  # load_and_authorize_resource :document, through: :circus, shallow: true
  before_action :set_circus, only: [ :new, :create ]
  before_action :set_document, only: [ :edit, :update, :destroy ]



  # 📄 Listado general de documentos visibles para el usuario
  def index
    @documents = Document.includes(:user, :circus)
                         .where(circus_id: current_user.circuses.pluck(:id))
                         .order(created_at: :desc)
  end

  # ➕ Formulario para crear nuevo documento
  def new
    # Circunscribe el documento al circo recibido por parámetro
    @document = Document.new(circus_id: params[:circus_id])

    # Autorización específica (por si Cancancan falla por nil)
    authorize! :create, @document
  end

  # ✅ Crea el documento
  def create
    @document = current_user.documents.build(document_params)
    authorize! :create, @document

    if @document.save
      redirect_to documents_path, notice: "Documento subido correctamente"
    else
      render :new, status: :unprocessable_entity
    end
  end


  # ✏️ Editar documento
  def edit
    @document = Document.find(params[:id]) # ⬅️ Asegura que esté definido
    authorize! :edit, @document
  end

  # 🔄 Actualizar documento
  def update
    if @document.update(document_params)
      redirect_to by_circus_documents_path(@document.circus_id), notice: t("documents.notices.updated")
    else
      render :edit, status: :unprocessable_entity
    end
  end

  # 🗑️ Eliminar documento
  def destroy
    circus_id = @document.circus_id
    @document.destroy
    redirect_to by_circus_documents_path(circus_id), notice: t("documents.notices.deleted")
  end

  # 🎪 Ver documentos por circo
  def by_circus
    @circus = current_user.circuses.find(params[:circus_id])
    documents_scope = @circus.documents.includes(:user, :tags)

    if params[:query].present?
      q = params[:query].downcase
      documents_scope = documents_scope.where("LOWER(title) LIKE ? OR EXISTS (SELECT 1 FROM taggings INNER JOIN tags ON tags.id = taggings.tag_id WHERE taggings.taggable_id = documents.id AND taggings.taggable_type = 'Document' AND LOWER(tags.name) LIKE ?)", "%#{q}%", "%#{q}%")
    end

    if params[:type].present?
      documents_scope = documents_scope.where(document_type: params[:type])
    end

    @pagy, @documents = pagy(documents_scope.order(created_at: :desc))
  end

  private

  # 🔐 Parámetros seguros
  def document_params
    params.require(:document).permit(
      :title,
      :description,
      :document_type,
      :circus_id,
      :file,
      :tag_list
    )
  end
  def set_circus
    circus_id = params[:circus_id] || params.dig(:document, :circus_id)
    @circus = current_user.circuses.find(circus_id)
  end
  def set_document
    @document = Document.find(params[:id])
  end
end

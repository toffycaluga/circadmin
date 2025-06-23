class Ability
  include CanCan::Ability

  def initialize(user)
    # Evita errores si el usuario no está logueado
    return unless user

    if user.superadmin?
      can :manage, :all
    end


    # === 🎪 CIRCOS ===

    # Puede ver cualquier circo donde esté asociado
    can :read, Circus, circus_users: { user_id: user.id }

    # Puede acceder a la vista de administración si es owner o tiene invitación activa y aceptada
    can :admin, Circus do |circus|
      cu = user.circus_users.find_by(circus_id: circus.id)
      cu&.role == "owner" || (cu&.active? && cu&.accepted_at.present?)
    end

    # Puede gestionar totalmente el circo solo si es el dueño
    can :manage, Circus do |circus|
      cu = user.circus_users.find_by(circus_id: circus.id)
      cu&.role == "owner"
    end

    # === 📍 LOCALIDADES ===

    # Puede gestionar localidades si es owner o admin del circo
    can :manage, Locality do |locality|
      cu = user.circus_users.find_by(circus_id: locality.circus_id)
      cu&.role.in?(%w[owner admin])
    end

    # === 💸 TRANSACCIONES ===

    # Puede crear transacciones si es owner o admin en cualquier circo donde esté activo y aceptado
    can :create, Transaction do
      user.circus_users.any? do |cu|
        %w[owner admin].include?(cu.role) && cu.active? && cu.accepted_at.present?
      end
    end

    # Puede leer transacciones si pertenecen a un circo al que está asociado
    can :read, Transaction do |tx|
      user_circus_ids = user.circuses.pluck(:id)
      tx.circus_id.in?(user_circus_ids)
    end

    # === 👥 USUARIOS DEL CIRCO ===

    # Puede gestionar usuarios solo si es dueño del circo
    can :manage, CircusUser, circus: { id: user.owned_circuses.ids }

    # Puede editar su propia relación (activar/desactivar) si está activo
    can :manage, CircusUser, user_id: user.id, active: true

    # === 📂 DOCUMENTOS ===

    # Puede leer documentos dependiendo del tipo y su rol
    can :read, Document do |doc|
      cu = user.circus_users.find_by(circus_id: doc.circus_id)
      next false unless cu&.active? && cu&.accepted_at.present?

      case doc.document_type
      when "contract"
        cu.role.in?(%w[owner admin]) # contratos son privados
      else
        cu.role.in?(%w[owner admin representative]) # los demás son más abiertos
      end
    end

    # Puede subir documentos si tiene rol válido en ese circo
    can [ :new, :edit, :create ], Document do |doc|
      cu = user.circus_users.find_by(circus_id: doc.circus_id)
      cu&.role.in?(%w[owner admin representative]) &&
        cu.active? && cu.accepted_at.present?
    end

    # Solo admin y owner pueden editar/eliminar documentos
    can :manage, Document do |doc|
      cu = user.circus_users.find_by(circus_id: doc.circus_id)
      cu&.role.in?(%w[owner admin])
    end
  end
end

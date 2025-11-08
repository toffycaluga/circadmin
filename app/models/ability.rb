# app/models/ability.rb
class Ability
  include CanCan::Ability

  # circus es opcional. Si no lo pasas, todo funciona igual.
  def initialize(user, circus = nil)
    # Invitado (no autenticado)
    return unless user

    # === SUPERADMIN ===
    can :manage, :all if user.superadmin?

    # === SUSCRIPCIONES ===
    # Si viene un circo en contexto, autoriza solo si es owner de ese circo.
    if circus.present?
      cu = user.circus_users.find_by(circus_id: circus.id)
      can :manage, :subscription if cu&.role == "owner" && cu.active? && cu.accepted_at.present?
    else
      # Sin contexto: permite gestionar suscripciones si es owner activo en al menos un circo.
      can :manage, :subscription if user.circus_users.where(role: "owner", active: true).exists?
    end

    # === 🎪 CIRCOS ===

    # Puede ver cualquier circo donde esté asociado
    can :read, Circus, circus_users: { user_id: user.id }

    # Puede acceder a la vista de administración si es owner o tiene invitación activa y aceptada
    can :admin, Circus do |c|
      cu = user.circus_users.find_by(circus_id: c.id)
      cu&.role == "owner" || (cu&.active? && cu&.accepted_at.present?)
    end

    # Puede gestionar totalmente el circo solo si es el dueño
    can :manage, Circus do |c|
      cu = user.circus_users.find_by(circus_id: c.id)
      cu&.role == "owner"
    end

    # === 📍 LOCALIDADES ===

    # Puede gestionar localidades si es owner o admin del circo
    can :manage, Locality do |loc|
      cu = user.circus_users.find_by(circus_id: loc.circus_id)
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
      user_circus_ids.include?(tx.circus_id)
    end

    # === 👥 USUARIOS DEL CIRCO (CircusUser) ===

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

    # Puede subir/editar documentos si tiene rol válido en ese circo
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

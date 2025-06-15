class Ability
  include CanCan::Ability

  def initialize(user)
    return unless user

    # Puede leer cualquier circo donde esté asociado
    can :read, Circus, circus_users: { user_id: user.id }

    # Puede acceder a admin si está activo y aceptó la invitación
    can :admin, Circus do |circus|
      cu = user.circus_users.find_by(circus_id: circus.id)
      cu&.role == "owner" || (cu&.active? && cu&.accepted_at.present?)
    end

    # ✅ Agregado: puede gestionar el circo si es owner
    can :manage, Circus do |circus|
      cu = user.circus_users.find_by(circus_id: circus.id)
      cu&.role == "owner"
    end

    # Puede gestionar localidades si es owner o admin
    can :manage, Locality do |locality|
      cu = user.circus_users.find_by(circus_id: locality.circus_id)
      cu&.role.in? %w[owner admin]
    end

    # Puede crear transacciones si es owner o admin en algún circo
    can :create, Transaction do
      user.circus_users.any? { |cu| %w[owner admin].include?(cu.role) && cu.active? && cu.accepted_at.present? }
    end

    can :read, Transaction do |tx|
      user_circus_ids = user.circuses.pluck(:id)
      tx.circus_id.in?(user_circus_ids)
    end


    # Puede administrar usuarios si es dueño
    can :manage, CircusUser, circus: { id: user.owned_circuses.ids }

    # Puede editar su propio rol activo
    can :manage, CircusUser, user_id: user.id, active: true
  end
end

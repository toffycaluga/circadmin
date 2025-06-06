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



    # Puede administrar usuarios si es dueño
    can :manage, CircusUser, circus: { id: user.owned_circuses.ids }

    # Puede editar su propio rol activo
    can :manage, CircusUser, user_id: user.id, active: true
  end
end

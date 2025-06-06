# frozen_string_literal: true

class Ability
  include CanCan::Ability

  def initialize(user)
    return unless user

    can :read, Circus, circus_users: { user_id: user.id }

    if user.owned_circuses.any?
      can :admin, Circus, circus_users: { user_id: user.id, role: "owner" }
      can :manage, CircusUser, circus: { id: user.owned_circuses.pluck(:id) }
    end
    can :manage, CircusUser, user_id: user.id, active: true

  end
end

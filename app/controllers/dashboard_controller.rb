class DashboardController < ApplicationController
  before_action :authenticate_user!
  def index
    @circuses = current_user.circuses
    @owned_circuses = current_user.owned_circuses
    owned_ids = @owned_circuses.map(&:id)

    @associated_circuses = current_user
      .associated_circuses
      .joins(:circus_users)
      .where(circus_users: { user_id: current_user.id, active: true })
      .where.not(circus_users: { accepted_at: nil })
      .where.not(id: owned_ids)
      .distinct
  end
end

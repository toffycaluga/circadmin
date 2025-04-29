class DashboardController < ApplicationController
  def index
    @circuses = current_user.circuses
    @owned_circuses = current_user.owned_circuses
    owned_ids = @owned_circuses.map(&:id)
    @associated_circuses = current_user.associated_circuses.where.not(id: owned_ids)
  end
end

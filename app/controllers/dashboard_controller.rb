class DashboardController < ApplicationController
  def index
    @circuses=current_user.circuses
  end
end

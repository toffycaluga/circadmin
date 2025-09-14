class HomeController < ApplicationController
  def index
    @stats = [
      { emoji: "👥",  label: "Usuarios registrados",     value: User.count },
      { emoji: "🎪",  label: "Circos activos",           value: Circus.count }
    ]
    @plans = Plan.active.order(:price_cents)
    if user_signed_in?
      redirect_to dashboard_index_path
    end
  end
end

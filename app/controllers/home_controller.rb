class HomeController < ApplicationController
  def index
    @stats = [
      { emoji: "👥", label: t("home.stats.users_registered"), value: User.count },
      { emoji: "🎪", label: t("home.stats.active_circuses"),  value: Circus.count }
    ]

    @plans = Plan.active.order(:price_cents)
    redirect_to dashboard_index_path if user_signed_in?
  end
end

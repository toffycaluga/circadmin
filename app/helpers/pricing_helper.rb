# app/helpers/pricing_helper.rb
module PricingHelper
  def plan_features(plan)
    feats = Array(I18n.t("plans.#{plan.key}.features", default: []))
    feats.presence || I18n.t("plans.default.features")
  end


  def plan_subtitle(plan)
    I18n.t("plans.#{plan.key}.subtitle",
      default: I18n.t("plans.default.subtitle"))
  end

  def plan_frequency
    I18n.t("subscriptions.new.month")
  end

  def plan_cta_text(plan)
    plan.trial_days.to_i.positive? ?
      I18n.t("subscriptions.new.start_trial") :
      I18n.t("subscriptions.new.pay_now")
  end

  # Si estás dentro de un circo, pásalo como @circus; si no, cae a registro o root.
  def plan_cta_url(plan, circus: nil)
    if circus.present?
      new_circus_subscription_path(circus, plan_id: plan.id)
    elsif respond_to?(:new_user_registration_path)
      new_user_registration_path(plan_id: plan.id)
    else
      root_path
    end
  end
end

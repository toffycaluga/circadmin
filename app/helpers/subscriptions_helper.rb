# app/helpers/subscriptions_helper.rb
module SubscriptionsHelper
  def plan_label_for(subscription, stripe_sub)
    stripe_sub&.items&.data&.first&.price&.nickname ||
      stripe_sub&.items&.data&.first&.price&.id ||
      subscription.try(:plan)&.try(:name) ||
      (subscription.respond_to?(:plan_nickname) ? subscription.plan_nickname : nil) ||
      (subscription.respond_to?(:plan_id) ? subscription.plan_id : nil) ||
      "—"
  end
end

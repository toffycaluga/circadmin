# frozen_string_literal: true

module Stripe
  class SubscriptionService
    def initialize(circus:)
      @circus = circus
      @subscription_id = circus.stripe_subscription_id
      raise ArgumentError, "Missing circus.stripe_subscription_id" if @subscription_id.blank?
    end

    def fetch
      ::Stripe::Subscription.retrieve(@subscription_id)
    end

    def pause
      ::Stripe::Subscription.update(@subscription_id, {
        pause_collection: { behavior: "mark_uncollectible" } # o 'keep_as_draft'/'void'
      })
    end

    def resume
      ::Stripe::Subscription.update(@subscription_id, { pause_collection: "" })
    end

    def cancel_immediately
      ::Stripe::Subscription.cancel(@subscription_id) # baja inmediata
    end

    def cancel_at_period_end
      ::Stripe::Subscription.update(@subscription_id, { cancel_at_period_end: true })
    end

    def uncancel
      ::Stripe::Subscription.update(@subscription_id, { cancel_at_period_end: false })
    end

    # opcional: sincronizar cache local
    def sync_cache!
      sub = fetch
      @circus.update!(
        stripe_subscription_status: sub.status,
        stripe_current_period_end:  Time.at(sub.current_period_end).to_datetime,
        stripe_cancel_at_period_end: sub.cancel_at_period_end,
        stripe_pause_collection: sub.pause_collection.presence
      )
      sub
    end
  end
end

Rails.application.routes.draw do
  # Métodos de pago (Payment Methods) - idealmente POST/DELETE, pero mantengo tus GET por ahora
  get "payment_methods/index"
  get "payment_methods/new"
  get "payment_methods/create"
  get "payment_methods/destroy"

  # Autenticación Devise
  devise_for :users, controllers: {
    sessions:      "users/sessions",
    registrations: "users/registrations",
    passwords:     "users/passwords",
    confirmations: "users/confirmations",
    unlocks:       "users/unlocks",
    invitations:   "users/invitations"
  }

  # Dashboard y páginas básicas
  get "dashboard/index"
  get "home/index"
  get "errors/not_found"

  # Cambio de idioma
  post "set_language", to: "application#set_language"

  # Perfil de usuario
  get  "profile", to: "user_profiles#profile", as: :profile
  resources :user_profiles, only: [ :new, :create, :edit, :update ] do
    member do
      patch :profile_picture
      patch :update_profile_picture
    end
  end

  # Webhook de Stripe
  post "/webhooks/stripe", to: "stripe_webhooks#create"

  # Localidades (evita duplicar este resources: ya estaba más abajo)
  resources :localities do
    member do
      get   :admin
      get   "transactions/summary_details", to: "transactions#summary_details", as: :summary_details_transactions
      get   "summary", to: "localities#summary"
      get   :overview_transactions, to: "transactions#overview"
      get   :insights
      patch :deactivate
      patch :reactivate
    end
  end

  # Documentos
  resources :documents, only: [ :index, :new, :create, :edit, :update, :destroy ] do
    collection do
      get "circus/:circus_id", to: "documents#by_circus", as: :by_circus
    end
  end

  # Nómina y gastos
  resources :payrolls, only: [ :show ] do
    resources :payroll_items, only: [ :create, :edit, :update, :destroy ]
    member do
      patch :mark_as_paid
      post  :register_expense
      get   :confirm_expense
    end
  end

  # Circuses y administración de suscripciones
  resources :circuses do
    # Payrolls anidados para crear y listar
    resources :payrolls, only: [ :new, :create ]

    # Suscripción singular por circo
    resource :subscription, only: [ :new, :show, :create, :update ] do
      # Verificar disponibilidad (JSON). En singular resource NO hace falta on:
      get  :check_availability, defaults: { format: :json }
      post :pause
      post :resume
    end

    member do
      patch :toggle_status
      get   :admin
      get   :accept_invitation, to: "circuses#accept_invitation"
    end
  end

  # Asociación de usuarios a circos
  resources :circus_users, only: [ :edit, :update ] do
    member do
      patch :deactivate
    end
  end

  # Invitaciones personalizadas
  post "custom_invite", to: "custom_invitations#create", as: :custom_invite
  post "admin/invite_user", to: "admin/users#invite", as: :invite_user

  # Invitaciones (invitations) generales
  resources :invitations do
    member do
      patch :accept
      patch :reject
      post  :resend_email
    end
  end
  resources :custom_invitations, only: [] do
    member do
      post :resend_email
    end
  end

  # Rutas de notificaciones
  resources :notifications do
    member do
      patch :mark_as_read
    end
    collection do
      patch :mark_all_as_read
    end
  end

  # Transacciones
  resources :transactions do
    collection do
      get :export_pdf
      get :export_excel
      get :new_income
      get :new_expense
    end
    member do
      get :card
    end
  end

  # Límite de elementos del circo (si esto usa @circus en el controller, conviene moverlo a /circuses/:id/...)
  get "circuses/check_limit", to: "circuses#check_limit"

  # Root y redirecciones según autenticación
  root to: "home#index"
  authenticated :user do
    root to: "dashboard#index", as: :authenticated_root
  end
  unauthenticated do
    root to: "devise/sessions#new", as: :unauthenticated_root
  end

  # ⛔️ Elimina la top-level que rompía todo:
  # get 'subscriptions/check_availability', to: 'subscriptions#check_availability', defaults: { format: :json }

  # Rutas de error y fallback (siempre al final)
  match "/404",       to: "errors#not_found", via: :all
  match "*unmatched", to: "errors#not_found", via: :all, constraints: ->(req) {
    !req.path.starts_with?("/rails/active_storage")
  }
end

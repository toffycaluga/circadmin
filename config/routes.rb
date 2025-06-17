Rails.application.routes.draw do
  resources :localities
  # resources :transactions
  # Autenticación Devise
  devise_for :users, controllers: {
    sessions: "users/sessions",
    registrations: "users/registrations",
    passwords: "users/passwords",
    confirmations: "users/confirmations",
    unlocks: "users/unlocks",
    invitations: "users/invitations"
  }


  # Dashboard y páginas básicas
  get "dashboard/index"
  get "home/index"
  get "errors/not_found"

  # get :export_pdf, on: :collection


  # Cambio de idioma
  post "set_language", to: "application#set_language"

  # Perfil de usuario
  get "profile", to: "user_profiles#profile", as: :profile
  resources :user_profiles, only: [ :new, :create, :edit, :update ] do
    member do
      patch :profile_picture
      patch :update_picture
    end
  end
  # config/routes.rb
  resources :localities do
    member do
      get :admin
      get "transactions/summary_details", to: "transactions#summary_details", as: :summary_details_transactions
      get "summary", to: "localities#summary"
      get :overview_transactions, to: "transactions#overview"
      get :insights
      patch :deactivate
      patch :reactivate
    end
  end


  # Circuses y administración
  resources :circuses do
    member do
      get :admin
      get :accept_invitation, to: "circuses#accept_invitation"
    end
  end

  # Asociación de usuarios a circos
  resources :circus_users, only: [ :edit, :update ] do
    member do
      patch :deactivate
    end
  end

  # Invitaciones internas
  post "/custom_invite", to: "custom_invitations#create", as: :custom_invite
  post "admin/invite_user", to: "admin/users#invite", as: :invite_user

  resources :invitations do
    member do
      patch :accept
      patch :reject
      post :resend_email
    end
  end
  resources :custom_invitations, only: [] do
    member do
      post :resend_email
    end
  end

  # Root y redirecciones autenticadas
  root to: "home#index"
  authenticated :user do
    root to: "dashboard#index", as: :authenticated_root
  end
  unauthenticated do
    root to: "devise/sessions#new", as: :unauthenticated_root
  end


  resources :notifications, only: [ :index ] do
    member do
      patch :mark_as_read
    end
    collection do
      patch :mark_all_as_read
    end
  end
  # get "transactions/overview", to: "transactions#overview", as: :overview_transactions
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
  # Rutas de error y fallback
  match "/404", to: "errors#not_found", via: :all
  match "*unmatched", to: "errors#not_found", via: :all, constraints: ->(req) {
    !req.path.starts_with?("/rails/active_storage")
  }
end

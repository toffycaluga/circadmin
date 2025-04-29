Rails.application.routes.draw do
  resources :circuses do
    member do
      get :admin
      get :accept_invitation, to: "circuses#accept_invitation"
    end
  end
  post "admin/invite_user", to: "admin/users#invite", as: :invite_user

  # Rutas básicas
  get "errors/not_found"
  get "dashboard/index"
  get "home/index"

  # Perfil personalizado
  get "profile", to: "user_profiles#profile", as: :profile

  # Perfil REST (CRUD)
  resources :user_profiles, only: [ :new, :create, :edit, :update ] do
    member do
      patch :profile_picture
      patch :update_picture
    end
  end

  devise_for :users, controllers: {
    sessions: "users/sessions",
    registrations: "users/registrations",
    passwords: "users/passwords",
    confirmations: "users/confirmations",
    unlocks: "users/unlocks",
    # omniauth_callbacks: "users/omniauth_callbacks",
    invitations: "users/invitations" # <-- esto es nuevo
  }

  # Cambiar idioma
  post "set_language", to: "application#set_language"

  # Root y redirecciones autenticadas
  root to: "home#index"
  authenticated :user do
    root to: "dashboard#index", as: :authenticated_root
  end
  unauthenticated do
    root to: "devise/sessions#new", as: :unauthenticated_root
  end

  # Rutas de error
  match "/404", to: "errors#not_found", via: :all
  match "*unmatched", to: "errors#not_found", via: :all, constraints: lambda { |req|
    !req.path.starts_with?("/rails/active_storage")
  }
end

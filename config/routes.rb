Rails.application.routes.draw do
  get "errors/not_found"
  get "dashboard/index"
  get "home/index"
  resources :user_profiles, only: [:new, :create, :edit, :update]

  devise_for :users
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  get "up" => "rails/health#show", as: :rails_health_check

  # Render dynamic PWA files from app/views/pwa/* (remember to link manifest in application.html.erb)
  # get "manifest" => "rails/pwa#manifest", as: :pwa_manifest
  # get "service-worker" => "rails/pwa#service_worker", as: :pwa_service_worker
  root to: "home#index"

  # ruta para cambiar idioma
  post "set_language", to: "application#set_language"

  authenticated :user do
    root to: "dashboard#index", as: :authenticated_root
  end

  unauthenticated do
    root to: "devise/sessions#new", as: :unauthenticated_root
  end
  # config/routes.rb
  match "/404", to: "errors#not_found", via: :all
  # config/routes.rb (al final del archivo)
  match "*unmatched", to: "errors#not_found", via: :all

  # Defines the root path route ("/")
  # root "posts#index"
end

Rails.application.routes.draw do
  get "up" => "rails/health#show", as: :rails_health_check

  root "landing#index"

  get "login", to: "sessions#new"
  post "login", to: "sessions#create"
  delete "logout", to: "sessions#destroy"

  get "/auth/google_oauth2/callback", to: "sessions#oauth_callback"
  get "/auth/failure", to: "sessions#oauth_failure"

  get "dashboard", to: "dashboard#index", as: :dashboard

  resources :clientes
  resources :veiculos do
    member do
      get :retirar_frota, to: "veiculos#retirar_frota_form"
      post :retirar_frota
      get :new_manutencao
      post :manutencao
    end
    collection do
      get :new_manutencao
    end
    resources :anexos, only: [ :create, :destroy ]
  end
  resources :locacoes
  resources :eventos do
    resources :anexos, only: [ :destroy ]
  end
  resources :socios
  resources :usuarios
  resources :participacao_socios

  resource :pagamento_semanal, only: :create
end

Rails.application.routes.draw do
  get "up" => "rails/health#show", as: :rails_health_check

  root "landing#index"

  get "login", to: "sessions#new"
  post "login", to: "sessions#create"
  delete "logout", to: "sessions#destroy"
  
  get "dashboard", to: "dashboard#index", as: :dashboard

  resources :clientes
  resources :veiculos
  resources :locacoes
  resources :eventos
  resources :socios
  resources :usuarios
  resources :participacao_socios

  resource :pagamento_semanal, only: :create
  resource :manutencao, only: [:create, :show]
end

Rails.application.routes.draw do
  get "up" => "rails/health#show", as: :rails_health_check

  root "dashboard#index"

  resources :clientes, only: :index
  resources :veiculos, only: :index
  resources :locacoes, only: :index
  resources :eventos, only: :index
  resources :socios, only: :index

  resource :pagamento_semanal, only: :create
  resource :manutencao, only: :create
end

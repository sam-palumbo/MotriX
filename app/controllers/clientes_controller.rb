class ClientesController < ApplicationController
  before_action :ensure_database_connected

  def index
    @clientes = Cliente.order(:nome)
  end
end

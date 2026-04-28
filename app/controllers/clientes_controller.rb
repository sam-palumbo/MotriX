class ClientesController < ApplicationController

  def index
    @clientes = Cliente.order(:nome)
  end
end

class VeiculosController < ApplicationController
  before_action :ensure_database_connected

  def index
    @veiculos = Veiculo.order(:placa)
  end
end

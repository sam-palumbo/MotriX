class VeiculosController < ApplicationController

  def index
    @veiculos = Veiculo.order(:placa)
  end
end

class LocacoesController < ApplicationController

  def index
    @locacoes = Locacao.includes(:cliente, :veiculo).order(data_inicio: :desc)
  end
end

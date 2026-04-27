class LocacoesController < ApplicationController
  before_action :ensure_database_connected

  def index
    @locacoes = Locacao.includes(:cliente, :veiculo).order(data_inicio: :desc)
  end
end

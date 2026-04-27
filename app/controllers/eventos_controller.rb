class EventosController < ApplicationController
  before_action :ensure_database_connected

  def index
    @eventos = Evento.includes(:cliente, :veiculo, :locacao).order(data_evento: :desc, created_at: :desc)
  end
end

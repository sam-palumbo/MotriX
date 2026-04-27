class SociosController < ApplicationController
  before_action :ensure_database_connected

  def index
    @socios = Socio.includes(participacao_socios: :veiculo).order(:nome)
  end
end

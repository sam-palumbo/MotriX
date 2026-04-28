class SociosController < ApplicationController

  def index
    @socios = Socio.includes(participacao_socios: :veiculo).order(:nome)
  end
end

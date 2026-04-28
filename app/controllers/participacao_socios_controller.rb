class ParticipacaoSociosController < ApplicationController
  before_action :set_participacao_socio, only: [ :show, :edit, :update, :destroy ]

  def index
    @participacao_socios = ParticipacaoSocio.includes(:socio, :veiculo).order(:socio_id, :veiculo_id)
  end

  def show
  end

  def new
    @participacao_socio = ParticipacaoSocio.new
    @socios = Socio.order(:nome)
    @veiculos = Veiculo.order(:placa)
  end

  def create
    @participacao_socio = ParticipacaoSocio.new(participacao_socio_params)
    @participacao_socio.created_by = current_usuario
    @participacao_socio.updated_by = current_usuario

    if @participacao_socio.save
      redirect_to @participacao_socio, notice: "ParticipacaoSocio was successfully created."
    else
      @socios = Socio.order(:nome)
      @veiculos = Veiculo.order(:placa)
      render :new, status: :unprocessable_entity
    end
  end

  def edit
    @socios = Socio.order(:nome)
    @veiculos = Veiculo.order(:placa)
  end

  def update
    @participacao_socio.updated_by = current_usuario
    if @participacao_socio.update(participacao_socio_params)
      redirect_to @participacao_socio, notice: "ParticipacaoSocio was successfully updated."
    else
      @socios = Socio.order(:nome)
      @veiculos = Veiculo.order(:placa)
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @participacao_socio.destroy
    redirect_to participacao_socios_url, notice: "ParticipacaoSocio was successfully deleted."
  end

  private

  def set_participacao_socio
    @participacao_socio = ParticipacaoSocio.find(params[:id])
  end

  def participacao_socio_params
    params.require(:participacao_socio).permit(:socio_id, :veiculo_id, :percentual_participacao, :valor_investido)
  end
end

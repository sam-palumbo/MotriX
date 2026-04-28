class EventosController < ApplicationController
  before_action :set_evento, only: [ :show, :edit, :update, :destroy ]

  def index
    @eventos = Evento.includes(:cliente, :veiculo, :locacao).order(data_evento: :desc, created_at: :desc)
  end

  def show
  end

  def new
    @evento = Evento.new
    @clientes = Cliente.order(:nome)
    @veiculos = Veiculo.order(:placa)
    @locacoes = Locacao.order(:numero_contrato)
    respond_to do |format|
      format.html
      format.turbo_stream
    end
  end

  def create
    @evento = Evento.new(evento_params)
    @evento.created_by = Current.usuario
    @evento.updated_by = Current.usuario

    respond_to do |format|
      if @evento.save
        format.html { redirect_to @evento, notice: "Evento was successfully created." }
        format.turbo_stream
      else
        @clientes = Cliente.order(:nome)
        @veiculos = Veiculo.order(:placa)
        @locacoes = Locacao.order(:numero_contrato)
        format.html { render :new, status: :unprocessable_entity }
        format.turbo_stream
      end
    end
  end

  def edit
    @clientes = Cliente.order(:nome)
    @veiculos = Veiculo.order(:placa)
    @locacoes = Locacao.order(:numero_contrato)
    respond_to do |format|
      format.html
      format.turbo_stream
    end
  end

  def update
    @evento.updated_by = Current.usuario
    respond_to do |format|
      if @evento.update(evento_params)
        format.html { redirect_to @evento, notice: "Evento was successfully updated." }
        format.turbo_stream
      else
        @clientes = Cliente.order(:nome)
        @veiculos = Veiculo.order(:placa)
        @locacoes = Locacao.order(:numero_contrato)
        format.html { render :edit, status: :unprocessable_entity }
        format.turbo_stream
      end
    end
  end

  def destroy
    @evento.destroy
    redirect_to eventos_url, notice: "Evento was successfully deleted."
  end

  private

  def set_evento
    @evento = Evento.find(params[:id])
  end

  def evento_params
    permitted = params.require(:evento).permit(:cliente_id, :veiculo_id, :locacao_id, :tipo_evento, :tipo_manutencao, :fluxo, :status, :valor, :periodo_inicio, :periodo_fim, :quilometragem, :responsavel, :descricao, :data_evento)
    permitted[:status] = permitted[:status].to_i if permitted[:status].present?
    permitted[:tipo_evento] = permitted[:tipo_evento].to_i if permitted[:tipo_evento].present?
    permitted[:tipo_manutencao] = permitted[:tipo_manutencao].to_i if permitted[:tipo_manutencao].present?
    permitted[:fluxo] = permitted[:fluxo].to_i if permitted[:fluxo].present?
    permitted
  end
end

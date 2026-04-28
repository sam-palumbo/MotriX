class LocacoesController < ApplicationController
  before_action :set_locacao, only: [ :show, :edit, :update, :destroy ]

  def index
    @locacoes = Locacao.includes(:cliente, :veiculo).order(data_inicio: :desc)
  end

  def show
  end

  def new
    @locacao = Locacao.new
    @clientes = Cliente.order(:nome)
    @veiculos = Veiculo.order(:placa)
  end

  def create
    @locacao = Locacao.new(locacao_params)
    @locacao.created_by = current_usuario
    @locacao.updated_by = current_usuario

    if @locacao.save
      redirect_to @locacao, notice: "Locacao was successfully created."
    else
      @clientes = Cliente.order(:nome)
      @veiculos = Veiculo.order(:placa)
      render :new, status: :unprocessable_entity
    end
  end

  def edit
    @clientes = Cliente.order(:nome)
    @veiculos = Veiculo.order(:placa)
  end

  def update
    @locacao.updated_by = current_usuario
    if @locacao.update(locacao_params)
      redirect_to @locacao, notice: "Locacao was successfully updated."
    else
      @clientes = Cliente.order(:nome)
      @veiculos = Veiculo.order(:placa)
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @locacao.destroy
    redirect_to locacoes_url, notice: "Locacao was successfully deleted."
  end

  private

  def set_locacao
    @locacao = Locacao.find(params[:id])
  end

  def locacao_params
    permitted = params.require(:locacao).permit(:numero_contrato, :cliente_id, :veiculo_id, :data_inicio, :data_prevista_fim, :data_fim, :valor_semanal, :caucao_valor, :caucao_recebida, :caucao_devolvida, :status, :observacoes)
    permitted[:status] = permitted[:status].to_i if permitted[:status].present?
    permitted
  end
end

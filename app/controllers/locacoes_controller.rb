class LocacoesController < ApplicationController
  before_action :set_locacao, only: [ :show, :edit, :update, :destroy ]
  include LoadAssociations

  def index
    @locacoes = Locacao.includes(:cliente, :veiculo).order(data_inicio: :desc).page(params[:page]).per(25)
  end

  def show
  end

  def new
    @locacao = Locacao.new
    load_clientes
    load_veiculos
    respond_to do |format|
      format.html
      format.turbo_stream
    end
  end

  def create
    @locacao = Locacao.new(locacao_params)
    @locacao.created_by = Current.usuario
    @locacao.updated_by = Current.usuario

    respond_to do |format|
      if @locacao.save
        format.html { redirect_to @locacao, notice: "Locacao was successfully created." }
        format.turbo_stream
      else
        load_clientes
        load_veiculos
        format.html { render :new, status: :unprocessable_entity }
        format.turbo_stream
      end
    end
  end

  def edit
    load_clientes
    load_veiculos
    respond_to do |format|
      format.html
      format.turbo_stream
    end
  end

  def update
    @locacao.updated_by = Current.usuario
    respond_to do |format|
      if @locacao.update(locacao_params)
        format.html { redirect_to @locacao, notice: "Locacao was successfully updated." }
        format.turbo_stream
      else
        load_clientes
        load_veiculos
        format.html { render :edit, status: :unprocessable_entity }
        format.turbo_stream
      end
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

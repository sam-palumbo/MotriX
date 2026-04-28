class VeiculosController < ApplicationController
  before_action :set_veiculo, only: [ :show, :edit, :update, :destroy ]

  def index
    @veiculos = Veiculo.order(:placa)
  end

  def show
  end

  def new
    @veiculo = Veiculo.new
    respond_to do |format|
      format.html
      format.turbo_stream
    end
  end

  def create
    @veiculo = Veiculo.new(veiculo_params)
    @veiculo.created_by = Current.usuario
    @veiculo.updated_by = Current.usuario

    respond_to do |format|
      if @veiculo.save
        format.html { redirect_to @veiculo, notice: "Veiculo was successfully created." }
        format.turbo_stream
      else
        format.html { render :new, status: :unprocessable_entity }
        format.turbo_stream
      end
    end
  end

  def edit
    respond_to do |format|
      format.html
      format.turbo_stream
    end
  end

  def update
    @veiculo.updated_by = Current.usuario
    respond_to do |format|
      if @veiculo.update(veiculo_params)
        format.html { redirect_to @veiculo, notice: "Veiculo was successfully updated." }
        format.turbo_stream
      else
        format.html { render :edit, status: :unprocessable_entity }
        format.turbo_stream
      end
    end
  end

  def destroy
    @veiculo.destroy
    redirect_to veiculos_url, notice: "Veiculo was successfully deleted."
  end

  private

  def set_veiculo
    @veiculo = Veiculo.find(params[:id])
  end

  def veiculo_params
    permitted = params.require(:veiculo).permit(:placa, :renavam, :chassi, :marca, :modelo, :ano, :cor, :data_compra, :valor_compra, :valor_aquisicao, :valor_semanal, :valor_diaria, :km_aquisicao, :km_atual, :status, :primeira_locacao_em, :caucao_retida)
    permitted[:status] = permitted[:status].to_i if permitted[:status].present?
    permitted
  end
end

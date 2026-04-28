class VeiculosController < ApplicationController
  before_action :set_veiculo, only: [ :show, :edit, :update, :destroy ]

  def index
    @veiculos = Veiculo.order(:placa)
  end

  def show
  end

  def new
    @veiculo = Veiculo.new
  end

  def create
    @veiculo = Veiculo.new(veiculo_params)
    @veiculo.created_by = current_usuario
    @veiculo.updated_by = current_usuario

    if @veiculo.save
      redirect_to @veiculo, notice: "Veiculo was successfully created."
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit
  end

  def update
    @veiculo.updated_by = current_usuario
    if @veiculo.update(veiculo_params)
      redirect_to @veiculo, notice: "Veiculo was successfully updated."
    else
      render :edit, status: :unprocessable_entity
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
    params.require(:veiculo).permit(:placa, :renavam, :chassi, :marca, :modelo, :ano, :cor, :data_compra, :valor_compra, :valor_aquisicao, :valor_semanal, :valor_diaria, :km_aquisicao, :km_atual, :status, :primeira_locacao_em, :caucao_retida)
  end
end

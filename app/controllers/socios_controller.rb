class SociosController < ApplicationController
  before_action :set_socio, only: [ :show, :edit, :update, :destroy ]

  def index
    @socios = Socio.includes(participacao_socios: :veiculo).order(:nome)
  end

  def show
  end

  def new
    @socio = Socio.new
  end

  def create
    @socio = Socio.new(socio_params)
    @socio.created_by = Current.usuario
    @socio.updated_by = Current.usuario

    if @socio.save
      redirect_to @socio, notice: "Socio was successfully created."
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit
  end

  def update
    @socio.updated_by = Current.usuario
    if @socio.update(socio_params)
      redirect_to @socio, notice: "Socio was successfully updated."
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @socio.destroy
    redirect_to socios_url, notice: "Socio was successfully deleted."
  end

  private

  def set_socio
    @socio = Socio.find(params[:id])
  end

  def socio_params
    params.require(:socio).permit(:cpf, :nome, :telefone, :email)
  end
end

class ClientesController < ApplicationController
  before_action :set_cliente, only: [ :show, :edit, :update, :destroy ]
  include EnumParamsConverter

  def index
    @clientes = Cliente.includes(:locacoes, :eventos).order(:nome).page(params[:page]).per(25)
  end

  def show
  end

  def new
    @cliente = Cliente.new
    respond_to do |format|
      format.html
      format.turbo_stream
    end
  end

  def create
    @cliente = Cliente.new(cliente_params)
    @cliente.created_by = Current.usuario
    @cliente.updated_by = Current.usuario

    respond_to do |format|
      if @cliente.save
        format.html { redirect_to @cliente, notice: "Cliente was successfully created." }
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
    @cliente.updated_by = Current.usuario
    respond_to do |format|
      if @cliente.update(cliente_params)
        format.html { redirect_to @cliente, notice: "Cliente was successfully updated." }
        format.turbo_stream
      else
        format.html { render :edit, status: :unprocessable_entity }
        format.turbo_stream
      end
    end
  end

  def destroy
    @cliente.destroy
    redirect_to clientes_url, notice: "Cliente was successfully deleted."
  end

  private

  def set_cliente
    @cliente = Cliente.find(params[:id])
  end

  def cliente_params
    permitted = params.require(:cliente).permit(:cpf, :nome, :telefone, :email, :endereco, :cidade, :estado, :cep, :cnh, :validade_cnh, :status, :observacoes)
    convert_enum_params(permitted, :status)
  end
end

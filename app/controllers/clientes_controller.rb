class ClientesController < ApplicationController
  before_action :set_cliente, only: [ :show, :edit, :update, :destroy ]

  def index
    @clientes = Cliente.order(:nome)
  end

  def show
  end

  def new
    @cliente = Cliente.new
  end

  def create
    @cliente = Cliente.new(cliente_params)
    @cliente.created_by = Current.usuario
    @cliente.updated_by = Current.usuario

    if @cliente.save
      redirect_to @cliente, notice: "Cliente was successfully created."
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit
  end

  def update
    @cliente.updated_by = Current.usuario
    if @cliente.update(cliente_params)
      redirect_to @cliente, notice: "Cliente was successfully updated."
    else
      render :edit, status: :unprocessable_entity
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
    permitted[:status] = permitted[:status].to_i if permitted[:status].present?
    permitted
  end
end

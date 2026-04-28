class UsuariosController < ApplicationController
  before_action :set_usuario, only: [ :show, :edit, :update, :destroy ]

  def index
    @usuarios = Usuario.order(:nome)
  end

  def show
  end

  def new
    @usuario = Usuario.new
  end

  def create
    @usuario = Usuario.new(usuario_params)

    if @usuario.save
      redirect_to @usuario, notice: "Usuario was successfully created."
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit
  end

  def update
    if @usuario.update(usuario_params)
      redirect_to @usuario, notice: "Usuario was successfully updated."
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @usuario.destroy
    redirect_to usuarios_url, notice: "Usuario was successfully deleted."
  end

  private

  def set_usuario
    @usuario = Usuario.find(params[:id])
  end

  def usuario_params
    permitted = params.require(:usuario).permit(:cpf, :nome, :email, :senha_hash, :perfil, :ativo, :created_by_id, :updated_by_id)
    permitted[:perfil] = permitted[:perfil].to_i if permitted[:perfil].present?
    permitted
  end
end

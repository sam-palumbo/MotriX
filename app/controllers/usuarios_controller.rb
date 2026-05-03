class UsuariosController < ApplicationController
  before_action :set_usuario, only: [ :show, :edit, :update, :destroy ]
  include EnumParamsConverter

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
    @usuario.created_by = Current.usuario
    @usuario.updated_by = Current.usuario

    if @usuario.save
      redirect_to @usuario, notice: "Usuario was successfully created."
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit
  end

  def update
    if usuario_params[:password].blank?
      params[:usuario].delete(:password)
      params[:usuario].delete(:password_confirmation)
    end

    @usuario.assign_attributes(usuario_params)
    @usuario.updated_by = Current.usuario

    if @usuario.save
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
    permitted = params.require(:usuario).permit(:cpf, :nome, :email, :password, :password_confirmation, :perfil, :ativo, :created_by_id, :updated_by_id)
    convert_enum_params(permitted, :perfil)
  end
end

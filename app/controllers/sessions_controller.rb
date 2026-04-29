class SessionsController < ApplicationController
  skip_before_action :require_login, only: [:new, :create]

  def new
    redirect_to dashboard_path if Current.usuario
  end

  def create
    usuario = Usuario.find_by(email: params[:email])
    
    if usuario&.authenticate(params[:password])
      if usuario.ativo?
        session[:usuario_id] = usuario.id
        redirect_to root_path, notice: "Login realizado com sucesso!"
      else
        redirect_to login_path, alert: "Seu usuário está inativo. Entre em contato com um administrador."
      end
    else
      redirect_to login_path, alert: "Email ou senha incorretos."
    end
  end

  def destroy
    session[:usuario_id] = nil
    Current.usuario = nil
    redirect_to login_path, notice: "Você saiu do sistema."
  end
end

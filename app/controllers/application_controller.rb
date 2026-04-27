class ApplicationController < ActionController::Base
  allow_browser versions: :modern

  before_action :set_current_usuario
  after_action { Current.reset }

  helper_method :database_connected?

  private

  def database_connected?
    @database_connected ||= begin
      ActiveRecord::Base.connection_pool.with_connection { ActiveRecord::Base.connection.active? }
    rescue StandardError
      false
    end
  end

  def ensure_database_connected
    return if database_connected?

    redirect_to root_path, alert: "Configure o PostgreSQL antes de acessar os dados do sistema."
  end

  def set_current_usuario
    return unless database_connected?

    Current.usuario = Usuario.order(:created_at).first
  rescue StandardError
    Current.usuario = nil
  end
end

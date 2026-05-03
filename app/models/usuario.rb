class Usuario < ApplicationRecord
  tracked_by_users optional: true

  unless respond_to?(:perfils)
    enum :perfil, { admin: 0, operador: 1, socio: 2 }, prefix: true
  end

  has_many :auditoria_logs, dependent: :restrict_with_exception

  has_secure_password validations: false

  validates :cpf, :nome, :email, :perfil, presence: true
  validates :cpf, :email, uniqueness: { case_sensitive: false }
  validates :password, presence: true, if: :password_required?

  def self.from_omniauth(auth)
    return nil if auth.nil? || auth.info.email.blank?

    usuario = find_by(google_uid: auth.uid) || find_by(email: auth.info.email)
    return nil if usuario.nil?

    usuario.update(google_uid: auth.uid) if usuario.google_uid.blank?
    usuario
  end

  def password_required?
    return false if google_uid.present?
    new_record? && password_digest.blank?
  end

  scope :ativos, -> { where(ativo: true) }
  scope :admin, -> { where(perfil: :admin) }
  scope :operador, -> { where(perfil: :operador) }
  scope :socio, -> { where(perfil: :socio) }

  def to_s
    nome
  end

  def perfil_text
    case perfil
    when "admin", 0
      "Administrador"
    when "operador", 1
      "Operador"
    when "socio", 2
      "Sócio"
    else
      "Desconhecido"
    end
  end

  def ativo?
    ativo == true
  end
end

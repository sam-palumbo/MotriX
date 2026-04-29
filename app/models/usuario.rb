class Usuario < ApplicationRecord
  tracked_by_users optional: true

  unless respond_to?(:perfils)
    enum :perfil, { admin: 0, operador: 1, socio: 2 }, prefix: true
  end

  has_many :auditoria_logs, dependent: :restrict_with_exception

  has_secure_password

  validates :cpf, :nome, :email, :perfil, presence: true
  validates :cpf, :email, uniqueness: true

  scope :ativos, -> { where(ativo: true) }

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

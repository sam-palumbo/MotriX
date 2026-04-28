class Usuario < ApplicationRecord
  tracked_by_users optional: true

  enum :perfil, { admin: 0, operador: 1, socio: 2 }

  has_many :auditoria_logs, dependent: :restrict_with_exception

  validates :cpf, :nome, :email, :senha_hash, :perfil, presence: true
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
end

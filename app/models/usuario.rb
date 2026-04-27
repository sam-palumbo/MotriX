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
end

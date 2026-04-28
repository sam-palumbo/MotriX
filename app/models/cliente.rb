class Cliente < ApplicationRecord
  tracked_by_users

  enum :status, { ativo: 0, bloqueado: 1, inativo: 2 }

  has_many :locacoes, dependent: :restrict_with_exception
  has_many :eventos, dependent: :nullify

  validates :cpf, :nome, :status, presence: true
  validates :cpf, uniqueness: true

  def to_s
    nome
  end

  def status_text
    status.to_s.humanize
  end

  def ativo?
    status == "ativo"
  end
end

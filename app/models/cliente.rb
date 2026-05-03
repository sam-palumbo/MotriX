class Cliente < ApplicationRecord
  tracked_by_users

  enum :status, { ativo: 0, bloqueado: 1, inativo: 2 }

  # Scopes
  scope :ativos, -> { where(status: :ativo) }
  scope :bloqueados, -> { where(status: :bloqueado) }
  scope :por_nome, -> { order(:nome) }
  scope :sem_locacao_ativa, -> {
    where.not(id: Locacao.where(status: :ativa).select(:cliente_id))
  }
  scope :com_locacao_ativa, -> {
    where(id: Locacao.where(status: :ativa).select(:cliente_id))
  }

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

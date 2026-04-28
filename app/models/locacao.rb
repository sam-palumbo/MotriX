class Locacao < ApplicationRecord
  tracked_by_users

  enum :status, { ativa: 0, encerrada: 1, inadimplente: 2, cancelada: 3 }

  belongs_to :cliente
  belongs_to :veiculo

  has_many :eventos, dependent: :nullify

  validates :numero_contrato, :data_inicio, :data_prevista_fim, :valor_semanal, :status, presence: true
  validates :numero_contrato, uniqueness: true
  validate :data_prevista_fim_nao_antecede_inicio
  validate :data_fim_nao_antecede_inicio

  def to_s
    numero_contrato
  end

  def status_text
    status.to_s.humanize
  end

  private

  def data_prevista_fim_nao_antecede_inicio
    return if data_inicio.blank? || data_prevista_fim.blank? || data_prevista_fim >= data_inicio

    errors.add(:data_prevista_fim, "deve ser maior ou igual a data de inicio")
  end

  def data_fim_nao_antecede_inicio
    return if data_inicio.blank? || data_fim.blank? || data_fim >= data_inicio

    errors.add(:data_fim, "deve ser maior ou igual a data de inicio")
  end
end

class Evento < ApplicationRecord
  tracked_by_users

  enum :tipo_evento, {
    pagamento_semanal: 0,
    manutencao: 1,
    gasto_empresa: 2,
    retirada: 3,
    devolucao: 4,
    aquisicao_veiculo: 5,
    saida_frota: 6
  }
  enum :tipo_manutencao, {
    troca_oleo: 0,
    pneu: 1,
    freio: 2,
    corrente: 3,
    revisao: 4,
    outros: 5
  }, prefix: true
  enum :fluxo, { entrada: 0, saida: 1 }
  enum :status, { pendente: 0, pago: 1, parcial: 2 }, prefix: true

  belongs_to :cliente, optional: true
  belongs_to :veiculo, optional: true
  belongs_to :locacao, optional: true

  has_many :anexos, dependent: :nullify

  validates :tipo_evento, :fluxo, :valor, :responsavel, :data_evento, presence: true
  validates :tipo_manutencao, presence: true, if: :manutencao?
  validates :status, presence: true, if: :pagamento_semanal?
  validates :locacao, presence: true, if: :pagamento_semanal?
  validates :veiculo, presence: true, if: :manutencao?
  validate :periodo_fim_nao_antecede_inicio

  private

  def periodo_fim_nao_antecede_inicio
    return if periodo_inicio.blank? || periodo_fim.blank? || periodo_fim >= periodo_inicio

    errors.add(:periodo_fim, "deve ser maior ou igual ao periodo inicial")
  end
end

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
    troca_de_oleo: 0,
    troca_da_relacao: 1,
    pastilhas_de_freio_dianteira: 2,
    disco_de_freio_dianteiro: 3,
    lona_de_freio_traseira: 4,
    pneu_dianteiro: 5,
    pneu_traseiro: 6,
    vela_de_ignicao: 7,
    lona_de_freio_dianteira: 8,
    outros: 9
  }, prefix: true
  enum :fluxo, { entrada: 0, saida: 1 }
  enum :status, { pendente: 0, pago: 1, parcial: 2 }, prefix: true

  # Scopes
  scope :entradas, -> { where(fluxo: :entrada) }
  scope :saidas, -> { where(fluxo: :saida) }
  scope :pagamentos_semanais, -> { where(tipo_evento: :pagamento_semanal) }
  scope :manutencoes, -> { where(tipo_evento: :manutencao) }
  scope :retiradas, -> { where(tipo_evento: :retirada) }
  scope :devolucoes, -> { where(tipo_evento: :devolucao) }
  scope :por_data, -> { order(data_evento: :desc, created_at: :desc) }
  scope :do_veiculo, ->(veiculo_id) { where(veiculo_id: veiculo_id) }
  scope :do_cliente, ->(cliente_id) { where(cliente_id: cliente_id) }
  scope :da_locacao, ->(locacao_id) { where(locacao_id: locacao_id) }
  scope :no_periodo, ->(inicio, fim) { where(data_evento: inicio..fim) }

  belongs_to :cliente, optional: true
  belongs_to :veiculo, optional: true
  belongs_to :locacao, optional: true

  has_many :anexos, dependent: :nullify

  validates :tipo_evento, :fluxo, :valor, :responsavel, :data_evento, presence: true

  def tipo_evento_text
    tipo_evento.to_s.humanize
  end

  def fluxo_text
    fluxo.to_s.humanize
  end

  def status_text
    status.to_s.humanize
  end

  def tipo_manutencao_text
    tipo_manutencao.to_s.humanize
  end

  def entrada?
    fluxo == "entrada"
  end
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

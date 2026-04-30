class Veiculo < ApplicationRecord
  tracked_by_users

  enum :status, { disponivel: 0, locado: 1, manutencao: 2, inativo: 3 }

  has_many :locacoes, dependent: :restrict_with_exception
  has_many :eventos, dependent: :nullify
  has_many :participacao_socios, dependent: :destroy
  has_many :socios, through: :participacao_socios
  has_many :anexos, dependent: :destroy

  validates :placa, :renavam, :chassi, :status, presence: true
  validates :placa, :renavam, :chassi, uniqueness: true

  def to_s
    [ placa, marca, modelo ].compact.join(" - ")
  end

  def status_text
    status.to_s.humanize
  end

  def taxa_retorno
    return 0 if valor_compra.nil? || valor_compra.zero?
    retorno_total.to_f / valor_compra.to_f
  end

  def retorno_total
    eventos.where(fluxo: "entrada").sum(:valor) - eventos.where(fluxo: "saida").sum(:valor)
  end
end

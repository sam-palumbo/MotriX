class ParticipacaoSocio < ApplicationRecord
  self.table_name = "participacao_socios"

  tracked_by_users

  belongs_to :socio
  belongs_to :veiculo

  validates :percentual_participacao, presence: true, numericality: { greater_than: 0, less_than_or_equal_to: 100 }
  validates :valor_investido, numericality: { greater_than_or_equal_to: 0 }, allow_nil: true
  validates :socio_id, uniqueness: { scope: :veiculo_id }
end

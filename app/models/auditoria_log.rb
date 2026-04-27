class AuditoriaLog < ApplicationRecord
  belongs_to :usuario
  belongs_to :veiculo, optional: true

  validates :acao, :tipo_evento, presence: true
end

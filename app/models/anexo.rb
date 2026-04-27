class Anexo < ApplicationRecord
  tracked_by_users

  belongs_to :veiculo
  belongs_to :evento, optional: true

  validates :categoria, :nome_arquivo, :arquivo_url, :mime_type, presence: true
end

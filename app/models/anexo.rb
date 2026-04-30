class Anexo < ApplicationRecord
  tracked_by_users

  belongs_to :veiculo
  belongs_to :evento, optional: true

  validates :categoria, :nome_arquivo, :arquivo_url, :mime_type, presence: true
  validate :arquivo_url_must_be_google_drive

  private

  def arquivo_url_must_be_google_drive
    return if arquivo_url.blank?

    unless arquivo_url.match?(/\Ahttps?:\/\/(drive\.google\.com|docs\.google\.com)/i)
      errors.add(:arquivo_url, "deve ser uma URL válida do Google Drive")
    end
  end
end

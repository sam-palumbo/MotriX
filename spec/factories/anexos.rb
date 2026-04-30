FactoryBot.define do
  factory :anexo do
    veiculo
    categoria { "documento" }
    nome_arquivo { "documento.pdf" }
    arquivo_url { "https://drive.google.com/file/d/1234567890/view" }
    mime_type { "application/pdf" }
    association :created_by, factory: :usuario
    association :updated_by, factory: :usuario
  end
end

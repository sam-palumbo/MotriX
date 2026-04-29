FactoryBot.define do
  factory :anexo do
    veiculo
    categoria { "documento" }
    nome_arquivo { "documento.pdf" }
    arquivo_url { "https://example.com/documento.pdf" }
    mime_type { "application/pdf" }
    association :created_by, factory: :usuario
    association :updated_by, factory: :usuario
  end
end

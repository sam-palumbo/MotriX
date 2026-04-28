FactoryBot.define do
  factory :evento do
    veiculo
    tipo_evento { 0 } # manutencao
    fluxo { 0 }
    valor { Faker::Number.decimal(l_digits: 3, r_digits: 2) }
    responsavel { Faker::Name.name }
    descricao { Faker::Lorem.sentence }
    data_evento { Faker::Date.backward(days: 7) }
    association :created_by, factory: :usuario
    association :updated_by, factory: :usuario
  end
end

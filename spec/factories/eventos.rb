FactoryBot.define do
  factory :evento do
    tipo_evento { 0 } # manutencao
    fluxo { 0 }
    valor { Faker::Number.decimal(l_digits: 3, r_digits: 2) }
    responsavel { Faker::Name.name }
    descricao { Faker::Lorem.sentence }
    data_evento { Faker::Date.backward(days: 7) }
    association :created_by, factory: :usuario
    association :updated_by, factory: :usuario

    trait :manutencao do
      tipo_evento { 1 }
      veiculo
      tipo_manutencao { 0 }
    end

    trait :pagamento_semanal do
      tipo_evento { 0 }
      fluxo { 0 }
      status { 1 }
      locacao
    end
  end
end

FactoryBot.define do
  factory :locacao do
    veiculo
    cliente
    numero_contrato { "LOC#{Faker::Number.number(digits: 6)}" }
    data_inicio { Faker::Date.backward(days: 30) }
    data_prevista_fim { Faker::Date.forward(days: 30) }
    valor_semanal { Faker::Number.decimal(l_digits: 3, r_digits: 2) }
    status { 0 } # ativa
    association :created_by, factory: :usuario
    association :updated_by, factory: :usuario
    
    trait :ativa do
      status { 0 }
    end

    trait :finalizada do
      status { 1 }
    end

    trait :cancelada do
      status { 2 }
    end
  end
end

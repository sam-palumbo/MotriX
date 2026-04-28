FactoryBot.define do
  factory :veiculo do
    sequence(:placa) { |n| "ABC#{Faker::Number.number(digits: 3)}#{n}" }
    sequence(:renavam) { |n| "#{Faker::Number.number(digits: 9)}#{n.to_s.rjust(2, '0')}" }
    sequence(:chassi) { |n| "#{Faker::Vehicle.vin[0..15]}#{n.to_s.rjust(2, '0')}" }
    marca { Faker::Vehicle.make }
    modelo { Faker::Vehicle.model }
    status { 0 } # disponivel
    ano { Faker::Number.between(from: 2000, to: 2024) }
    cor { Faker::Vehicle.color }
    association :created_by, factory: :usuario
    association :updated_by, factory: :usuario

    trait :disponivel do
      status { 0 }
    end

    trait :locado do
      status { 1 }
    end

    trait :manutencao do
      status { 2 }
    end

    trait :inativo do
      status { 3 }
    end

    trait :with_locacoes do
      after(:create) do |veiculo|
        create_list(:locacao, 2, veiculo: veiculo)
      end
    end

    trait :with_eventos do
      after(:create) do |veiculo|
        create_list(:evento, 2, veiculo: veiculo)
      end
    end

    trait :with_socios do
      after(:create) do |veiculo|
        create_list(:participacao_socio, 2, veiculo: veiculo)
      end
    end
  end
end

FactoryBot.define do
  factory :participacao_socio do
    veiculo
    socio
    percentual_participacao { Faker::Number.decimal(l_digits: 2, r_digits: 2) }
    association :created_by, factory: :usuario
    association :updated_by, factory: :usuario
  end
end

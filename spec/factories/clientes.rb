FactoryBot.define do
  factory :cliente do
    nome { Faker::Name.name }
    cpf { Faker::Number.number(digits: 11).to_s }
    telefone { Faker::PhoneNumber.phone_number }
    email { Faker::Internet.email }
    endereco { Faker::Address.full_address }
    status { 0 } # ativo
    association :created_by, factory: :usuario
    association :updated_by, factory: :usuario
  end
end

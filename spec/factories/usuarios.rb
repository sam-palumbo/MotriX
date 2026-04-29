FactoryBot.define do
  factory :usuario do
    sequence(:cpf) { |n| Faker::Number.number(digits: 11).to_s + n.to_s }
    nome { Faker::Name.name }
    email { Faker::Internet.email }
    password { "password123" }
    password_confirmation { "password123" }
    perfil { :operador }
    ativo { true }

    trait :admin do
      perfil { :admin }
    end

    trait :operador do
      perfil { :operador }
    end

    trait :socio do
      perfil { :socio }
    end

    trait :inativo do
      ativo { false }
    end
  end
end

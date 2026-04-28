FactoryBot.define do
  factory :usuario do
    cpf { Faker::CPF.numeric }
    nome { Faker::Name.name }
    email { Faker::Internet.email }
    senha_hash { "hashed_password_#{rand(1000)}" }
    perfil { 1 } # operador
    ativo { true }
    
    trait :admin do
      perfil { 0 }
    end
    
    trait :operador do
      perfil { 1 }
    end
    
    trait :socio do
      perfil { 2 }
    end
    
    trait :inativo do
      ativo { false }
    end
  end
end

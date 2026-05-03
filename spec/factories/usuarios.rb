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

    trait :oauth do
      transient do
        skip_password { true }
      end
      password { nil }
      password_confirmation { nil }
      google_uid { "google-#{SecureRandom.uuid}" }

      after(:build) do |usuario, evaluator|
        usuario.password_digest = nil if evaluator.skip_password
      end

      before(:create) do |usuario, evaluator|
        usuario.password_digest = nil if evaluator.skip_password
      end
    end

    trait :with_oauth_and_password do
      google_uid { "google-#{SecureRandom.uuid}" }
    end
  end
end

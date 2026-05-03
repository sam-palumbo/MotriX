module OauthHelpers
  def mock_google_auth(email:, uid: SecureRandom.uuid, name: "Test User")
    OmniAuth.config.mock_auth[:google_oauth2] = OmniAuth::AuthHash.new({
      provider: "google_oauth2",
      uid: uid,
      info: {
        email: email,
        name: name
      }
    })
    Rails.application.env_config["omniauth.auth"] = OmniAuth.config.mock_auth[:google_oauth2]
  end

  def clear_oauth_mock
    OmniAuth.config.mock_auth[:google_oauth2] = nil
    Rails.application.env_config["omniauth.auth"] = nil
  end
end

RSpec.configure do |config|
  config.include OauthHelpers, type: :request

  config.after(:each, type: :request) do
    clear_oauth_mock
  end
end

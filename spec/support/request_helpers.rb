module RequestHelpers
  def login_as(usuario)
    post login_path, params: { email: usuario.email, password: "password123" }
    expect(response).to redirect_to(root_path)
  end
end

RSpec.configure do |config|
  config.include RequestHelpers, type: :request
end

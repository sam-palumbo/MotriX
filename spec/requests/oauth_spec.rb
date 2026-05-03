require "rails_helper"

RSpec.describe "Google OAuth Authentication", type: :request do
  describe "GET /auth/google_oauth2/callback" do
    context "when user exists and is active" do
      let!(:usuario) { create(:usuario, email: "user@example.com", ativo: true) }

      before do
        mock_google_auth(email: "user@example.com", uid: "123456789")
      end

      it "logs in the user" do
        get "/auth/google_oauth2/callback"
        expect(session[:usuario_id]).to eq(usuario.id)
      end

      it "redirects to root path" do
        get "/auth/google_oauth2/callback"
        expect(response).to redirect_to(root_path)
      end

      it "sets flash notice" do
        get "/auth/google_oauth2/callback"
        expect(flash[:notice]).to eq("Login realizado com sucesso!")
      end

      it "updates google_uid" do
        get "/auth/google_oauth2/callback"
        expect(usuario.reload.google_uid).to eq("123456789")
      end
    end

    context "when user exists but is inactive" do
      let!(:usuario) { create(:usuario, :inativo, email: "inactive@example.com") }

      before do
        mock_google_auth(email: "inactive@example.com", uid: "999999")
      end

      it "does not log in the user" do
        get "/auth/google_oauth2/callback"
        expect(session[:usuario_id]).to be_nil
      end

      it "redirects to login path" do
        get "/auth/google_oauth2/callback"
        expect(response).to redirect_to(login_path)
      end

      it "sets flash alert about inactive user" do
        get "/auth/google_oauth2/callback"
        expect(flash[:alert]).to include("inativo")
      end
    end

    context "when user does not exist" do
      before do
        mock_google_auth(email: "nonexistent@example.com", uid: "999999")
      end

      it "does not create a new user" do
        expect {
          get "/auth/google_oauth2/callback"
        }.not_to change(Usuario, :count)
      end

      it "redirects to login path" do
        get "/auth/google_oauth2/callback"
        expect(response).to redirect_to(login_path)
      end

      it "sets flash alert about user not found" do
        get "/auth/google_oauth2/callback"
        expect(flash[:alert]).to include("não cadastrado")
      end
    end

    context "when OAuth authentication fails" do
      before do
        OmniAuth.config.mock_auth[:google_oauth2] = :invalid_credentials
        Rails.application.env_config["omniauth.auth"] = nil
      end

      it "redirects to failure path" do
        get "/auth/google_oauth2/callback"
        expect(response).to redirect_to("/auth/failure?message=invalid_credentials&strategy=google_oauth2")
      end
    end
  end

  describe "GET /auth/failure" do
    it "redirects to login path" do
      get "/auth/failure", params: { message: "access_denied" }
      expect(response).to redirect_to(login_path)
    end

    it "sets flash alert with error message" do
      get "/auth/failure", params: { message: "access_denied" }
      expect(flash[:alert]).to include("Falha na autenticação")
    end
  end

  describe "CSRF protection" do
    it "requires POST for OAuth initiation" do
      expect(OmniAuth.config.request_validation_phase).not_to be_nil
    end
  end

  describe "backward compatibility with password login" do
    let!(:usuario) { create(:usuario, email: "legacy@example.com", password: "password123") }

    it "still works with password login" do
      post login_path, params: { email: usuario.email, password: "password123" }
      expect(session[:usuario_id]).to eq(usuario.id)
      expect(response).to redirect_to(root_path)
    end

    it "rejects invalid password" do
      post login_path, params: { email: usuario.email, password: "wrongpassword" }
      expect(session[:usuario_id]).to be_nil
      expect(response).to redirect_to(login_path)
    end
  end

  describe "hybrid users (both OAuth and password)" do
    let!(:hybrid_user) do
      create(:usuario, :with_oauth_and_password,
             email: "hybrid@example.com",
             password: "password123",
             google_uid: "google-123")
    end

    it "can login with password" do
      post login_path, params: { email: hybrid_user.email, password: "password123" }
      expect(session[:usuario_id]).to eq(hybrid_user.id)
    end

    it "can login with OAuth" do
      mock_google_auth(email: hybrid_user.email, uid: hybrid_user.google_uid)
      get "/auth/google_oauth2/callback"
      expect(session[:usuario_id]).to eq(hybrid_user.id)
    end
  end
end

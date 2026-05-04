require "rails_helper"

RSpec.describe Usuario, "OAuth functionality", type: :model do
  describe ".from_omniauth" do
    let(:auth_hash) do
      OmniAuth::AuthHash.new({
        provider: "google_oauth2",
        uid: "123456789",
        info: {
          email: "test@example.com",
          name: "Test User"
        }
      })
    end

    context "when user exists with matching email" do
      let!(:existing_user) { create(:usuario, email: "test@example.com") }

      it "finds the user by email" do
        user = Usuario.from_omniauth(auth_hash)
        expect(user).to eq(existing_user)
      end

      it "updates google_uid if not set" do
        expect {
          Usuario.from_omniauth(auth_hash)
        }.to change { existing_user.reload.google_uid }.from(nil).to("123456789")
      end

      it "does not create a new user" do
        expect {
          Usuario.from_omniauth(auth_hash)
        }.not_to change(Usuario, :count)
      end
    end

    context "when user exists with matching google_uid" do
      let!(:existing_user) do
        create(:usuario, :oauth, email: "test@example.com", google_uid: "123456789")
      end

      it "finds the user by google_uid" do
        user = Usuario.from_omniauth(auth_hash)
        expect(user).to eq(existing_user)
      end
    end

    context "when user does not exist" do
      it "does not create a new user" do
        expect {
          Usuario.from_omniauth(auth_hash)
        }.not_to change(Usuario, :count)
      end

      it "returns nil" do
        user = Usuario.from_omniauth(auth_hash)
        expect(user).to be_nil
      end
    end

    context "when auth hash is nil" do
      it "returns nil" do
        user = Usuario.from_omniauth(nil)
        expect(user).to be_nil
      end
    end

    context "when auth email is blank" do
      let(:auth_no_email) do
        OmniAuth::AuthHash.new({
          provider: "google_oauth2",
          uid: "123456789",
          info: { email: "" }
        })
      end

      it "returns nil" do
        user = Usuario.from_omniauth(auth_no_email)
        expect(user).to be_nil
      end
    end

    context "when user exists but is inactive" do
      let!(:inactive_user) do
        create(:usuario, :inativo, email: "test@example.com")
      end

      it "returns the inactive user" do
        user = Usuario.from_omniauth(auth_hash)
        expect(user).to eq(inactive_user)
      end
    end
  end

  describe "#password_required?" do
    context "for OAuth user without password" do
      let(:oauth_user) { build(:usuario, :oauth) }

      it "returns false" do
        expect(oauth_user.password_required?).to be false
      end
    end

    context "for password user" do
      let(:password_user) { build(:usuario) }

      it "returns false when password is already set" do
        expect(password_user.password_required?).to be false
      end

      context "without password set" do
        let(:password_user) { build(:usuario, password: nil, password_confirmation: nil) }

        it "returns true for new record" do
          expect(password_user.password_required?).to be true
        end
      end
    end

    context "for user with both OAuth and password" do
      let(:hybrid_user) { build(:usuario, :with_oauth_and_password) }

      it "returns false when OAuth is linked" do
        expect(hybrid_user.password_required?).to be false
      end
    end

    context "for existing OAuth user" do
      let!(:existing_oauth_user) { create(:usuario, :oauth) }

      it "returns false when editing" do
        existing_oauth_user.nome = "Updated Name"
        expect(existing_oauth_user.password_required?).to be false
      end
    end
  end

  describe "validations for OAuth user" do
    context "OAuth user without password" do
      let(:oauth_user) { build(:usuario, :oauth) }

      it "is valid without password" do
        expect(oauth_user).to be_valid
      end

      it "does not validate password presence" do
        oauth_user.password = nil
        expect(oauth_user).to be_valid
      end

      it "can be saved" do
        expect { oauth_user.save! }.not_to raise_error
      end
    end

    context "regular user without password" do
      let(:regular_user) { build(:usuario, password: nil, password_confirmation: nil) }

      it "is invalid without password" do
        expect(regular_user).not_to be_valid
      end

      it "has password error" do
        regular_user.valid?
        expect(regular_user.errors[:password]).to include("can't be blank")
      end
    end

    context "hybrid user" do
      let(:hybrid_user) { build(:usuario, :with_oauth_and_password) }

      it "is valid with both OAuth and password" do
        expect(hybrid_user).to be_valid
      end
    end
  end
end

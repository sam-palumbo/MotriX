require 'rails_helper'

RSpec.describe "Veiculos", type: :request do
  let(:admin) { create(:usuario, perfil: :admin) }

  around do |example|
    # Set up session and Current.usuario for the request
    post login_path, params: { email: admin.email, password: "password123" }
    example.run
    delete logout_path
  end

  describe "POST /veiculos" do
    context "with valid parameters" do
      let(:valid_params) { { veiculo: attributes_for(:veiculo) } }

      it "creates a new Veiculo and redirects" do
        expect {
          post veiculos_path, params: valid_params
        }.to change(Veiculo, :count).by(1)
        expect(response).to redirect_to(veiculo_path(Veiculo.order(:created_at).last))
        expect(flash[:notice]).to eq("Veiculo was successfully created.")
      end
    end

    context "with invalid parameters" do
      let(:invalid_params) { { veiculo: attributes_for(:veiculo, placa: nil) } }

      it "does not create a Veiculo and returns 422 Unprocessable Entity" do
        expect {
          post veiculos_path, params: invalid_params
        }.to change(Veiculo, :count).by(0)

        expect(response).to have_http_status(:unprocessable_content)
      end
    end
  end
end

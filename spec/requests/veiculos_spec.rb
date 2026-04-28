require 'rails_helper'

RSpec.describe "Veiculos", type: :request do
  let(:admin) { create(:usuario, perfil: :admin) }

  describe "POST /veiculos" do
    context "with valid parameters" do
      it "creates a new Veiculo and redirects" do
        expect {
          post veiculos_path, params: { veiculo: attributes_for(:veiculo) }
        }.to change(Veiculo, :count).by(1)
        expect(response).to redirect_to(veiculo_path(Veiculo.order(:created_at).last))
      end
    end

    context "with invalid parameters (testing modal 422 behavior)" do
      it "does not create a Veiculo and returns 422 Unprocessable Entity" do
        expect {
          # Intentionally sending empty params to trigger validation failure
          post veiculos_path, params: { veiculo: attributes_for(:veiculo, placa: nil) }
        }.to change(Veiculo, :count).by(0)
        
        # This is CRITICAL for the JS modal to work:
        # It must return 422 so the fetch `.catch()` block or `!response.ok` condition correctly renders the form errors
        expect(response).to have_http_status(:unprocessable_entity)
      end
    end
  end
end

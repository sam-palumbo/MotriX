require 'rails_helper'

RSpec.describe "EventosControllers", type: :request do
  let(:usuario) { create(:usuario, :operador) }

  before do
    # Simulate login by setting session
    post login_path, params: { email: usuario.email, password: 'password123' }
  end

  describe "GET /index" do
    it "returns a successful response" do
      get eventos_path
      expect(response).to have_http_status(:success)
    end

    it "includes pagination" do
      create_list(:evento, 30, :manutencao)
      get eventos_path
      expect(response).to have_http_status(:success)
    end
  end

  describe "GET /show" do
    let(:evento) { create(:evento, :manutencao) }

    it "returns a successful response" do
      get evento_path(evento)
      expect(response).to have_http_status(:success)
    end
  end

  describe "GET /new" do
    it "returns a successful response" do
      get new_evento_path
      expect(response).to have_http_status(:success)
    end
  end

  describe "POST /create" do
    context "with valid parameters" do
      let(:locacao) { create(:locacao) }
      let(:valid_params) do
        {
          evento: attributes_for(:evento, :pagamento_semanal).merge(
            locacao_id: locacao.id,
            cliente_id: locacao.cliente_id,
            veiculo_id: locacao.veiculo_id
          )
        }
      end

      it "creates a new Evento" do
        expect {
          post eventos_path, params: valid_params
        }.to change(Evento, :count).by(1)
      end

      it "redirects to the created evento" do
        expect {
          post eventos_path, params: valid_params
        }.to change(Evento, :count).by(1)
        
        expect(response).to redirect_to(evento_path(assigns(:evento)))
      end
    end

    context "with invalid parameters" do
      it "does not create a new Evento" do
        expect {
          post eventos_path, params: { evento: { tipo_evento: nil } }
        }.not_to change(Evento, :count)
      end

      it "renders a successful response (i.e. to display the 'new' template)" do
        post eventos_path, params: { evento: { tipo_evento: nil } }
        expect(response).to have_http_status(:unprocessable_content)
      end
    end
  end
end

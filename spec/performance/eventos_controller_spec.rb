require 'rails_helper'

RSpec.describe "EventosController Performance", type: :request do
  let(:usuario) { create(:usuario, :admin) }

  before do
    post login_path, params: { email: usuario.email, password: 'password123' }
  end

  describe "GET /index" do
    it "loads index page efficiently with many records" do
      create_list(:evento, 50, :manutencao)

      start_time = Time.current
      get eventos_path
      end_time = Time.current

      response_time = (end_time - start_time) * 1000 # in ms

      expect(response).to have_http_status(:success)
      expect(response_time).to be < 2000 # Should load in under 2s (environment may vary)
    end

    it "does not produce N+1 queries with includes" do
      clientes = create_list(:cliente, 10)
      veiculos = create_list(:veiculo, 10)

      10.times do |i|
        create(:evento, :pagamento_semanal, cliente: clientes[i], veiculo: veiculos[i])
      end

      query_count = 0
      subscriber = ActiveSupport::Notifications.subscribe('sql.active_record') do |*|
        query_count += 1
      end

      get eventos_path

      ActiveSupport::Notifications.unsubscribe(subscriber)

      # Should use includes to limit queries
      expect(query_count).to be < 8 # Should be around 4-5 queries with includes
    end

    it "uses pagination correctly" do
      create_list(:evento, 50, :manutencao)

      get eventos_path

      expect(response).to have_http_status(:success)
      expect(assigns(:eventos).count).to be <= 25 # Per page limit
    end
  end

  describe "Model scopes performance" do
    it "filters using scopes efficiently" do
      # Track baseline before creating test data
      baseline_saidas = Evento.saidas.count
      baseline_entradas = Evento.entradas.count

      create_list(:evento, 30, :manutencao, fluxo: :saida)
      create_list(:evento, 20, :pagamento_semanal, fluxo: :entrada)

      start_time = Time.current
      saidas = Evento.saidas.count
      entradas = Evento.entradas.count
      end_time = Time.current

      response_time = (end_time - start_time) * 1000

      expect(saidas - baseline_saidas).to eq(30)
      expect(entradas - baseline_entradas).to eq(20)
      expect(response_time).to be < 500 # Should be fast with proper indexes
    end
  end
end

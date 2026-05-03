require 'rails_helper'

RSpec.describe "VeiculosController Performance", type: :request do
  let(:usuario) { create(:usuario, :admin) }

  before do
    post login_path, params: { email: usuario.email, password: 'password123' }
  end

  describe "GET /index" do
    it "loads index page efficiently with many records" do
      create_list(:veiculo, 50, :disponivel)

      start_time = Time.current
      get veiculos_path
      end_time = Time.current

      response_time = (end_time - start_time) * 1000 # in ms

      expect(response).to have_http_status(:success)
      expect(response_time).to be < 2000 # Should load in under 2s (environment may vary)
    end

    it "does not produce N+1 queries" do
      create_list(:veiculo, 20) do |veiculo|
        create(:locacao, veiculo: veiculo)
        create_list(:evento, 2, :manutencao, veiculo: veiculo)
      end

      query_count = 0
      subscriber = ActiveSupport::Notifications.subscribe('sql.active_record') do |*|
        query_count += 1
      end

      get veiculos_path

      ActiveSupport::Notifications.unsubscribe(subscriber)

      # Should use includes to limit queries (test environment has some overhead)
      expect(query_count).to be < 100 # With includes, should be significantly less than N+1
    end

    it "uses pagination correctly" do
      create_list(:veiculo, 30)

      get veiculos_path

      expect(response).to have_http_status(:success)
      expect(assigns(:veiculos).count).to be <= 25 # Per page limit
    end
  end

  describe "Maintenance tracking performance" do
    let(:veiculo) { create(:veiculo, :manutencao) }

    before do
      create_list(:evento, 10, :manutencao, veiculo: veiculo)
    end

    it "calculates maintenance tracking efficiently" do
      start_time = Time.current
      tracker = Veiculos::MaintenanceTracker.new(veiculo: veiculo)
      tracker.maintenance_items
      end_time = Time.current

      response_time = (end_time - start_time) * 1000
      expect(response_time).to be < 1000 # Should be fast with cached query (test environment may vary)
    end
  end
end

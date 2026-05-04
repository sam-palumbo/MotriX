require 'rails_helper'

RSpec.describe "ClientesController Performance", type: :request do
  let(:usuario) { create(:usuario, :admin) }

  before do
    post login_path, params: { email: usuario.email, password: 'password123' }
  end

  describe "GET /index" do
    it "loads index page efficiently with many records" do
      create_list(:cliente, 50, :ativo)

      start_time = Time.current
      get clientes_path
      end_time = Time.current

      response_time = (end_time - start_time) * 1000 # in ms

      expect(response).to have_http_status(:success)
      expect(response_time).to be < 2000 # Should load in under 2s (environment may vary)
    end

    it "does not produce N+1 queries" do
      clientes = create_list(:cliente, 15, :ativo)
      veiculos = create_list(:veiculo, 15)

      10.times do |i|
        create(:locacao, cliente: clientes[i], veiculo: veiculos[i])
        create_list(:evento, 2, :pagamento_semanal, cliente: clientes[i])
      end

      query_count = 0
      subscriber = ActiveSupport::Notifications.subscribe('sql.active_record') do |*|
        query_count += 1
      end

      get clientes_path

      ActiveSupport::Notifications.unsubscribe(subscriber)

      # Should use includes to limit queries
      expect(query_count).to be < 10 # Should be around 3-4 queries with includes
    end
  end

  describe "Clientes scopes performance" do
    it "scopes filter efficiently" do
      # Setup data and track baseline
      baseline_com_locacao = Cliente.com_locacao_ativa.count
      baseline_sem_locacao = Cliente.sem_locacao_ativa.count

      clientes_com_locacao = create_list(:cliente, 10, :ativo)
      clientes_sem_locacao = create_list(:cliente, 10, :ativo)
      veiculos = create_list(:veiculo, 10)

      10.times do |i|
        create(:locacao, :ativa, cliente: clientes_com_locacao[i], veiculo: veiculos[i])
      end

      start_time = Time.current
      com_locacao = Cliente.com_locacao_ativa.count
      sem_locacao = Cliente.sem_locacao_ativa.count
      end_time = Time.current

      response_time = (end_time - start_time) * 1000

      expect(com_locacao - baseline_com_locacao).to eq(10)
      expect(sem_locacao - baseline_sem_locacao).to eq(10)
      expect(response_time).to be < 500 # Should be fast with proper subquery
    end
  end
end

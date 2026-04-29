class DashboardController < ApplicationController
  def index
    return unless database_connected?

    # Basic counts
    @clientes_count = Cliente.count
    @veiculos_count = Veiculo.count
    @veiculos_disponiveis_count = Veiculo.disponivel.count
    @locacoes_ativas_count = Locacao.ativa.count
    
    # Enhanced data for new dashboard
    @veiculos = Veiculo.all
    @locacoes_ativas = Locacao.includes(:cliente, :veiculo).ativa
    @veiculos_disponiveis = Veiculo.disponivel.limit(5)
    @veiculos_em_manutencao = Veiculo.manutencao
    
    # Financial metrics
    @receita_mes_atual = Evento.entrada.where(data_evento: Date.current.beginning_of_month..Date.current.end_of_month).sum(:valor)
    @retorno_total = Evento.entrada.where(tipo_evento: :pagamento_semanal).sum(:valor)
    @investimento_total = Veiculo.sum(:valor_aquisicao)
    @taxa_retorno = @investimento_total > 0 ? (@retorno_total / @investimento_total) : 0
    
    # Monthly revenue for chart (last 6 months)
    @receita_mensal = {}
    @max_receita_mensal = 0
    
    6.times do |i|
      month_date = (Date.current - i.months)
      month_key = month_date.strftime("%b/%Y")
      revenue = Evento.entrada.where(
        data_evento: month_date.beginning_of_month..month_date.end_of_month
      ).sum(:valor)
      
      @receita_mensal[month_key] = revenue
      @max_receita_mensal = [@max_receita_mensal, revenue].max
    end
    
    # Maintenance tracking
    @manutencoes_vencidas = calculate_manutencoes_vencidas
    
    # Alerts system
    @alertas = generate_alerts
    
    # Legacy data for compatibility
    @receita_periodo = Evento.entrada.where(data_evento: 30.days.ago.to_date..Date.current).sum(:valor)
    @despesas_periodo = Evento.saida.where(data_evento: 30.days.ago.to_date..Date.current).sum(:valor)
    @eventos_recentes = Evento.includes(:cliente, :veiculo, :locacao).order(data_evento: :desc, created_at: :desc).limit(8)
    @socios = Socio.includes(participacao_socios: :veiculo).order(:nome).limit(4)
    @locacoes_para_pagamento = Locacao.includes(:cliente, :veiculo).where(status: %i[ativa inadimplente]).order(:numero_contrato)
    @veiculos_para_manutencao = Veiculo.order(:placa)
  end

  private

  def calculate_manutencoes_vencidas
    # This would typically check maintenance schedules
    # For now, return vehicles in maintenance status
    Veiculo.manutencao.count
  end

  def generate_alerts
    alerts = []
    
    # Overdue payments - check based on locacao status
    overdue_locacoes = @locacoes_ativas.where(status: :inadimplente)
    
    if overdue_locacoes.any?
      alerts << {
        tipo: 'red',
        icone: '!',
        titulo: "#{overdue_locacoes.count} pagamento(s) em atraso",
        descricao: 'Clientes com pagamentos atrasados',
        link: locacoes_path
      }
    end
    
    # Maintenance alerts
    if @manutencoes_vencidas > 0
      alerts << {
        tipo: 'orange',
        icone: '!',
        titulo: "#{@manutencoes_vencidas} manutenção(ões) vencida(s)",
        descricao: 'Serviços que precisam ser realizados',
        link: veiculos_path(status: 'manutencao')
      }
    end
    
    # Low availability
    if @veiculos_disponiveis_count < 3
      alerts << {
        tipo: 'yellow',
        icone: '!',
        titulo: 'Baixa disponibilidade',
        descricao: "Apenas #{@veiculos_disponiveis_count} motos disponíveis",
        link: veiculos_path
      }
    end
    
    alerts
  end
end

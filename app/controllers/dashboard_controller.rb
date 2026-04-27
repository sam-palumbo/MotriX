class DashboardController < ApplicationController
  def index
    return unless database_connected?

    @clientes_count = Cliente.count
    @veiculos_count = Veiculo.count
    @veiculos_disponiveis_count = Veiculo.disponivel.count
    @locacoes_ativas_count = Locacao.ativa.count
    @receita_periodo = Evento.entrada.where(data_evento: 30.days.ago.to_date..Date.current).sum(:valor)
    @despesas_periodo = Evento.saida.where(data_evento: 30.days.ago.to_date..Date.current).sum(:valor)
    @locacoes_ativas = Locacao.includes(:cliente, :veiculo).ativa.order(data_inicio: :desc).limit(5)
    @eventos_recentes = Evento.includes(:cliente, :veiculo, :locacao).order(data_evento: :desc, created_at: :desc).limit(8)
    @veiculos_em_manutencao = Veiculo.manutencao.order(updated_at: :desc).limit(5)
    @socios = Socio.includes(participacao_socios: :veiculo).order(:nome).limit(4)
    @locacoes_para_pagamento = Locacao.includes(:cliente, :veiculo).where(status: %i[ativa inadimplente]).order(:numero_contrato)
    @veiculos_para_manutencao = Veiculo.order(:placa)
  end
end

class PagamentosSemanaisController < ApplicationController
  before_action :ensure_database_connected

  def create
    locacao = Locacao.find(params[:locacao_id])

    Locacoes::RegistrarPagamentoSemanal.call(
      locacao: locacao,
      usuario: Current.usuario,
      valor: params[:valor],
      status: params[:status],
      periodo_inicio: params[:periodo_inicio],
      periodo_fim: params[:periodo_fim],
      data_evento: params[:data_evento],
      responsavel: params[:responsavel],
      descricao: params[:descricao]
    )

    redirect_to root_path, notice: "Pagamento semanal registrado com sucesso."
  rescue ActiveRecord::RecordInvalid => error
    redirect_to root_path, alert: error.record.errors.full_messages.to_sentence
  rescue StandardError => error
    redirect_to root_path, alert: error.message
  end
end

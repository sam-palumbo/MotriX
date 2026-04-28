class ManutencoesController < ApplicationController

  def create
    veiculo = Veiculo.find(params[:veiculo_id])

    Veiculos::RegistrarManutencao.call(
      veiculo: veiculo,
      usuario: Current.usuario,
      tipo_manutencao: params[:tipo_manutencao],
      valor: params[:valor],
      quilometragem: params[:quilometragem],
      data_evento: params[:data_evento],
      responsavel: params[:responsavel],
      descricao: params[:descricao]
    )

    redirect_to root_path, notice: "Manutencao registrada com sucesso."
  rescue ActiveRecord::RecordInvalid => error
    redirect_to root_path, alert: error.record.errors.full_messages.to_sentence
  rescue StandardError => error
    redirect_to root_path, alert: error.message
  end
end

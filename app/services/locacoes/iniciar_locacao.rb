module Locacoes
  class IniciarLocacao < ApplicationService
    def initialize(evento:, usuario:, params:)
      @evento = evento
      @usuario = usuario
      @params = params
    end

    def call
      raise ArgumentError, "Usuario responsavel nao encontrado." unless usuario

      ActiveRecord::Base.transaction do
        # Create a new Locacao record using form parameters
        locacao = Locacao.create!(
          cliente_id: evento.cliente_id,
          veiculo_id: evento.veiculo_id,
          numero_contrato: params[:numero_contrato] || "LOC-#{Time.current.to_i}",
          data_inicio: params[:evento][:data_inicio],
          data_prevista_fim: params[:evento][:data_prevista_fim],
          valor_semanal: params[:evento][:valor_semanal],
          caucao_valor: params[:caucao_valor],
          caucao_recebida: params[:caucao_valor].present?,
          status: :ativa,
          created_by: usuario,
          updated_by: usuario
        )

        # Update the evento to reference the locacao
        evento.update!(locacao_id: locacao.id)

        # Update vehicle status to locado
        evento.veiculo.update!(status: :locado)

        # Update vehicle caucao_retida if provided
        if params[:caucao_valor].present?
          evento.veiculo.update!(caucao_retida: params[:caucao_valor])
        end

        locacao
      end
    end

    private

    attr_reader :evento, :usuario, :params
  end
end

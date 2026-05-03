module Locacoes
  class EncerrarLocacao < ApplicationService
    def initialize(evento:, usuario:, params:)
      @evento = evento
      @usuario = usuario
      @params = params
    end

    def call
      raise ArgumentError, "Usuario responsavel nao encontrado." unless usuario

      ActiveRecord::Base.transaction do
        # Find the active locacao for this vehicle
        locacao = evento.veiculo.locacoes.ativa.first

        if locacao
          # Update locacao with end date from form parameter
          locacao.update!(
            data_fim: params[:data_fim],
            status: :encerrada,
            updated_by: usuario
          )

          # Update evento to reference the locacao
          evento.update!(locacao_id: locacao.id)
        end

        # Update vehicle status to disponivel
        evento.veiculo.update!(status: :disponivel)

        # Handle caução devolução
        if params[:devolucao_caucao].present?
          evento.veiculo.update!(caucao_retida: 0) # Clear retained deposit
        end

        locacao
      end
    end

    private

    attr_reader :evento, :usuario, :params
  end
end

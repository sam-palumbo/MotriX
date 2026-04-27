module Locacoes
  class RegistrarPagamentoSemanal < ApplicationService
    def initialize(locacao:, usuario:, valor:, status:, periodo_inicio:, periodo_fim:, data_evento:, responsavel:, descricao:)
      @locacao = locacao
      @usuario = usuario
      @valor = valor
      @status = status
      @periodo_inicio = periodo_inicio
      @periodo_fim = periodo_fim
      @data_evento = data_evento
      @responsavel = responsavel
      @descricao = descricao
    end

    def call
      raise ArgumentError, "Usuario responsavel nao encontrado." unless usuario

      ActiveRecord::Base.transaction do
        evento = Evento.create!(
          cliente: locacao.cliente,
          veiculo: locacao.veiculo,
          locacao: locacao,
          tipo_evento: :pagamento_semanal,
          fluxo: :entrada,
          status: normalized_status,
          valor: normalized_decimal(valor),
          periodo_inicio: normalized_date(periodo_inicio),
          periodo_fim: normalized_date(periodo_fim),
          responsavel: responsavel,
          descricao: descricao,
          data_evento: normalized_date(data_evento),
          created_by: usuario,
          updated_by: usuario
        )

        locacao.update!(status: locacao_status)

        AuditoriaLog.create!(
          usuario: usuario,
          veiculo: locacao.veiculo,
          acao: "registrou_pagamento_semanal",
          tipo_evento: "pagamento_semanal",
          valor: evento.valor,
          detalhes: "Contrato #{locacao.numero_contrato} com status #{evento.status}"
        )

        evento
      end
    end

    private

    attr_reader :locacao, :usuario, :valor, :status, :periodo_inicio, :periodo_fim, :data_evento, :responsavel, :descricao

    def normalized_status
      (status.presence || "pago").to_sym
    end

    def locacao_status
      normalized_status == :pago ? :ativa : :inadimplente
    end

    def normalized_date(value)
      return value if value.is_a?(Date)
      return if value.blank?

      Date.parse(value.to_s)
    end

    def normalized_decimal(value)
      BigDecimal(value.to_s)
    end
  end
end

module Veiculos
  class RegistrarManutencao < ApplicationService
    def initialize(veiculo:, usuario:, tipo_manutencao:, valor:, quilometragem:, data_evento:, responsavel:, descricao:)
      @veiculo = veiculo
      @usuario = usuario
      @tipo_manutencao = tipo_manutencao
      @valor = valor
      @quilometragem = quilometragem
      @data_evento = data_evento
      @responsavel = responsavel
      @descricao = descricao
    end

    def call
      raise ArgumentError, "Usuario responsavel nao encontrado." unless usuario

      ActiveRecord::Base.transaction do
        evento = Evento.create!(
          veiculo: veiculo,
          tipo_evento: :manutencao,
          tipo_manutencao: tipo_manutencao,
          fluxo: :saida,
          valor: normalized_decimal(valor),
          quilometragem: quilometragem.presence,
          responsavel: responsavel,
          descricao: descricao,
          data_evento: normalized_date(data_evento),
          created_by: usuario,
          updated_by: usuario
        )

        updates = { status: :manutencao }
        updates[:km_atual] = quilometragem.to_i if quilometragem.present?
        veiculo.update!(updates)

        AuditoriaLog.create!(
          usuario: usuario,
          veiculo: veiculo,
          acao: "registrou_manutencao",
          tipo_evento: "manutencao",
          valor: evento.valor,
          detalhes: "#{tipo_manutencao.to_s.humanize} para o veiculo #{veiculo.placa}"
        )

        evento
      end
    end

    private

    attr_reader :veiculo, :usuario, :tipo_manutencao, :valor, :quilometragem, :data_evento, :responsavel, :descricao

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

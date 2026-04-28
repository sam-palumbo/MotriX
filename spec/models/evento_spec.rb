require 'rails_helper'

RSpec.describe Evento, type: :model do
  describe "validations" do
    let(:cliente) { create(:cliente) }
    let(:veiculo) { create(:veiculo) }
    let(:locacao) { create(:locacao, cliente: cliente, veiculo: veiculo) }
    let(:admin) { create(:usuario, perfil: :admin) }

    it "is valid with minimum required attributes" do
      evento = build(:evento, fluxo: :entrada, tipo_evento: :pagamento_semanal, valor: 100, responsavel: admin.nome, status: :pago, locacao: locacao)
      expect(evento).to be_valid
    end

    describe "conditional validations based on tipo_evento" do
      context "when tipo_evento is pagamento_semanal" do
        it "is invalid if locacao is missing" do
          evento = build(:evento, tipo_evento: :pagamento_semanal, locacao: nil, status: :pago)
          expect(evento).not_to be_valid
          expect(evento.errors[:locacao]).not_to be_empty
        end
      end

      context "when tipo_evento is manutencao" do
        it "is invalid if veiculo is missing" do
          evento = build(:evento, tipo_evento: :manutencao, veiculo: nil, tipo_manutencao: :troca_oleo)
          expect(evento).not_to be_valid
          expect(evento.errors[:veiculo]).not_to be_empty
        end

        it "is invalid if tipo_manutencao is missing" do
          evento = build(:evento, tipo_evento: :manutencao, tipo_manutencao: nil, veiculo: veiculo)
          expect(evento).not_to be_valid
          expect(evento.errors[:tipo_manutencao]).not_to be_empty
        end
      end
    end
  end
end

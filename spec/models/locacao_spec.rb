require 'rails_helper'

RSpec.describe Locacao, type: :model do
  describe "validations" do
    let(:cliente) { create(:cliente) }
    let(:veiculo) { create(:veiculo) }
    let(:admin) { create(:usuario, perfil: :admin) }

    it "is valid with minimum required attributes" do
      locacao = build(:locacao, cliente: cliente, veiculo: veiculo)
      expect(locacao).to be_valid
    end

    it "requires a data_inicio" do
      locacao = build(:locacao, cliente: cliente, veiculo: veiculo, data_inicio: nil)
      expect(locacao).not_to be_valid
    end

    it "requires a numero_contrato" do
      locacao = build(:locacao, cliente: cliente, veiculo: veiculo, numero_contrato: nil)
      expect(locacao).not_to be_valid
    end
  end

  describe "status enum" do
    it "defines expected statuses" do
      expect(Locacao.statuses.keys).to include("ativa", "encerrada", "inadimplente", "cancelada")
    end
  end
end

require 'rails_helper'

RSpec.describe Veiculo, type: :model do
  describe "validations" do
    it "is valid with valid attributes" do
      veiculo = build(:veiculo)
      expect(veiculo).to be_valid
    end

    it "is invalid without a placa" do
      veiculo = build(:veiculo, placa: nil)
      expect(veiculo).not_to be_valid
      expect(veiculo.errors[:placa]).to include("can't be blank")
    end

    it "is invalid without a renavam" do
      veiculo = build(:veiculo, renavam: nil)
      expect(veiculo).not_to be_valid
      expect(veiculo.errors[:renavam]).to include("can't be blank")
    end

    it "is invalid without a chassi" do
      veiculo = build(:veiculo, chassi: nil)
      expect(veiculo).not_to be_valid
      expect(veiculo.errors[:chassi]).to include("can't be blank")
    end

    it "is invalid without a status" do
      veiculo = build(:veiculo, status: nil)
      expect(veiculo).not_to be_valid
      expect(veiculo.errors[:status]).to include("can't be blank")
    end
    
    it "validates uniqueness of placa" do
      create(:veiculo, placa: "ABC1234")
      veiculo = build(:veiculo, placa: "ABC1234")
      expect(veiculo).not_to be_valid
      expect(veiculo.errors[:placa]).to include("has already been taken")
    end

    it "validates uniqueness of renavam" do
      create(:veiculo, renavam: "123456789012")
      veiculo = build(:veiculo, renavam: "123456789012")
      expect(veiculo).not_to be_valid
      expect(veiculo.errors[:renavam]).to include("has already been taken")
    end

    it "validates uniqueness of chassi" do
      create(:veiculo, chassi: "ABCDEFGHIJKLMNOPQR")
      veiculo = build(:veiculo, chassi: "ABCDEFGHIJKLMNOPQR")
      expect(veiculo).not_to be_valid
      expect(veiculo.errors[:chassi]).to include("has already been taken")
    end
  end

  describe "associations" do
    it "has many locacoes" do
      veiculo = create(:veiculo)
      expect(veiculo).to respond_to(:locacoes)
    end

    it "has many eventos" do
      veiculo = create(:veiculo)
      expect(veiculo).to respond_to(:eventos)
    end

    it "has many participacao_socios" do
      veiculo = create(:veiculo)
      expect(veiculo).to respond_to(:participacao_socios)
    end

    it "has many socios through participacao_socios" do
      veiculo = create(:veiculo)
      expect(veiculo).to respond_to(:socios)
    end

    it "destroys dependent participacao_socios on destroy" do
      veiculo = create(:veiculo)
      create(:participacao_socio, veiculo: veiculo)
      
      expect { veiculo.destroy }.to change(ParticipacaoSocio, :count).by(-1)
    end

    it "restricts deletion if has locacoes" do
      veiculo = create(:veiculo)
      create(:locacao, veiculo: veiculo)
      
      expect { veiculo.destroy }.to raise_error(ActiveRecord::DeleteRestrictionError)
    end
  end

  describe "status enum" do
    it "defines expected statuses" do
      expect(Veiculo.statuses.keys).to include("disponivel", "locado", "manutencao", "inativo")
    end

    it "has default status of disponivel" do
      veiculo = create(:veiculo)
      expect(veiculo.status).to eq("disponivel")
    end
  end

  describe "#to_s" do
    it "returns placa, marca and modelo" do
      veiculo = build(:veiculo, placa: "ABC1234", marca: "Honda", modelo: "CG 160")
      expect(veiculo.to_s).to eq("ABC1234 - Honda - CG 160")
    end

    it "handles missing marca" do
      veiculo = build(:veiculo, placa: "ABC1234", marca: nil, modelo: "CG 160")
      expect(veiculo.to_s).to eq("ABC1234 - CG 160")
    end

    it "handles missing modelo" do
      veiculo = build(:veiculo, placa: "ABC1234", marca: "Honda", modelo: nil)
      expect(veiculo.to_s).to eq("ABC1234 - Honda")
    end
  end

  describe "#status_text" do
    it "returns humanized status" do
      veiculo = build(:veiculo, status: "disponivel")
      expect(veiculo.status_text).to eq("Disponivel")
    end

    it "returns humanized status for locado" do
      veiculo = build(:veiculo, status: "locado")
      expect(veiculo.status_text).to eq("Locado")
    end

    it "returns humanized status for manutencao" do
      veiculo = build(:veiculo, status: "manutencao")
      expect(veiculo.status_text).to eq("Manutencao")
    end

    it "returns humanized status for inativo" do
      veiculo = build(:veiculo, status: "inativo")
      expect(veiculo.status_text).to eq("Inativo")
    end
  end

  describe "#taxa_retorno" do
    it "returns 0 when valor_compra is nil" do
      veiculo = build(:veiculo, valor_compra: nil)
      expect(veiculo.taxa_retorno).to eq(0)
    end

    it "returns 0 when valor_compra is zero" do
      veiculo = build(:veiculo, valor_compra: 0)
      expect(veiculo.taxa_retorno).to eq(0)
    end

    it "calculates taxa_retorno correctly" do
      veiculo = create(:veiculo, valor_compra: 10000)
      create(:evento, :manutencao, veiculo: veiculo, fluxo: "entrada", valor: 5000, tipo_manutencao: "troca_oleo")
      create(:evento, :manutencao, veiculo: veiculo, fluxo: "saida", valor: 1000, tipo_manutencao: "pneu")
      
      expect(veiculo.taxa_retorno).to eq(0.4) # (5000 - 1000) / 10000
    end
  end

  describe "#retorno_total" do
    it "calculates total return from eventos" do
      veiculo = create(:veiculo)
      create(:evento, :manutencao, veiculo: veiculo, fluxo: "entrada", valor: 5000, tipo_manutencao: "troca_oleo")
      create(:evento, :manutencao, veiculo: veiculo, fluxo: "saida", valor: 1000, tipo_manutencao: "pneu")
      
      expect(veiculo.retorno_total).to eq(4000) # 5000 - 1000
    end

    it "returns 0 when no eventos exist" do
      veiculo = create(:veiculo)
      expect(veiculo.retorno_total).to eq(0)
    end
  end
end

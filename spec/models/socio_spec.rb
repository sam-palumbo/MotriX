require 'rails_helper'

RSpec.describe Socio, type: :model do
  describe "validations" do
    it "is valid with valid attributes" do
      socio = build(:socio)
      expect(socio).to be_valid
    end

    it "is invalid without a nome" do
      socio = build(:socio, nome: nil)
      expect(socio).not_to be_valid
      expect(socio.errors[:nome]).to include("can't be blank")
    end

    it "is invalid without a cpf" do
      socio = build(:socio, cpf: nil)
      expect(socio).not_to be_valid
      expect(socio.errors[:cpf]).to include("can't be blank")
    end

    it "validates uniqueness of cpf" do
      create(:socio, cpf: "12345678901")
      socio = build(:socio, cpf: "12345678901")
      expect(socio).not_to be_valid
      expect(socio.errors[:cpf]).to include("has already been taken")
    end
  end

  describe "associations" do
    it "has many participacao_socios" do
      socio = create(:socio)
      expect(socio).to respond_to(:participacao_socios)
    end

    it "has many veiculos through participacao_socios" do
      socio = create(:socio)
      expect(socio).to respond_to(:veiculos)
    end

    it "destroys dependent participacao_socios on destroy" do
      socio = create(:socio)
      create(:participacao_socio, socio: socio)
      
      expect { socio.destroy }.to change(ParticipacaoSocio, :count).by(-1)
    end
  end

  describe "#to_s" do
    it "returns the nome" do
      socio = build(:socio, nome: "João Silva")
      expect(socio.to_s).to eq("João Silva")
    end
  end

  describe "through associations" do
    it "can access veiculos through participacao_socios" do
      socio = create(:socio)
      veiculo = create(:veiculo)
      create(:participacao_socio, socio: socio, veiculo: veiculo)
      
      expect(socio.veiculos).to include(veiculo)
    end

    it "returns empty array when no participacao_socios exist" do
      socio = create(:socio)
      expect(socio.veiculos).to be_empty
    end
  end
end

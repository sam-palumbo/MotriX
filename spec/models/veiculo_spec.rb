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
    end

    it "is invalid without a renavam" do
      veiculo = build(:veiculo, renavam: nil)
      expect(veiculo).not_to be_valid
    end

    it "is invalid without a chassi" do
      veiculo = build(:veiculo, chassi: nil)
      expect(veiculo).not_to be_valid
    end
    
    it "validates uniqueness of placa" do
      create(:veiculo, placa: "ABC1234")
      veiculo = build(:veiculo, placa: "ABC1234")
      expect(veiculo).not_to be_valid
    end
  end

  describe "status enum" do
    it "defines expected statuses" do
      expect(Veiculo.statuses.keys).to include("disponivel", "locado", "manutencao", "inativo")
    end
  end
end

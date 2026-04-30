require 'rails_helper'

RSpec.describe ParticipacaoSocio, type: :model do
  describe "validations" do
    it "is valid with valid attributes" do
      participacao = build(:participacao_socio)
      expect(participacao).to be_valid
    end

    it "is invalid without a socio" do
      participacao = build(:participacao_socio, socio: nil)
      expect(participacao).not_to be_valid
    end

    it "is invalid without a veiculo" do
      participacao = build(:participacao_socio, veiculo: nil)
      expect(participacao).not_to be_valid
    end

    it "is invalid without percentual_participacao" do
      participacao = build(:participacao_socio, percentual_participacao: nil)
      expect(participacao).not_to be_valid
      expect(participacao.errors[:percentual_participacao]).to include("can't be blank")
    end

    it "validates percentual_participacao is greater than 0" do
      participacao = build(:participacao_socio, percentual_participacao: 0)
      expect(participacao).not_to be_valid
      expect(participacao.errors[:percentual_participacao]).to include("must be greater than 0")
    end

    it "validates percentual_participacao is less than or equal to 100" do
      participacao = build(:participacao_socio, percentual_participacao: 101)
      expect(participacao).not_to be_valid
      expect(participacao.errors[:percentual_participacao]).to include("must be less than or equal to 100")
    end

    it "allows valor_investido to be nil" do
      participacao = build(:participacao_socio, valor_investido: nil)
      expect(participacao).to be_valid
    end

    it "validates valor_investido is greater than or equal to 0 when present" do
      participacao = build(:participacao_socio, valor_investido: -100)
      expect(participacao).not_to be_valid
      expect(participacao.errors[:valor_investido]).to include("must be greater than or equal to 0")
    end

    it "validates uniqueness of socio_id scoped to veiculo_id" do
      socio = create(:socio)
      veiculo = create(:veiculo)
      create(:participacao_socio, socio: socio, veiculo: veiculo)

      participacao = build(:participacao_socio, socio: socio, veiculo: veiculo)
      expect(participacao).not_to be_valid
      expect(participacao.errors[:socio_id]).to include("has already been taken")
    end

    it "allows same socio for different veiculos" do
      socio = create(:socio)
      veiculo1 = create(:veiculo)
      veiculo2 = create(:veiculo)
      create(:participacao_socio, socio: socio, veiculo: veiculo1)

      participacao = build(:participacao_socio, socio: socio, veiculo: veiculo2)
      expect(participacao).to be_valid
    end

    it "allows different socios for same veiculo" do
      socio1 = create(:socio)
      socio2 = create(:socio)
      veiculo = create(:veiculo)
      create(:participacao_socio, socio: socio1, veiculo: veiculo)

      participacao = build(:participacao_socio, socio: socio2, veiculo: veiculo)
      expect(participacao).to be_valid
    end
  end

  describe "associations" do
    it "belongs to socio" do
      participacao = create(:participacao_socio)
      expect(participacao).to respond_to(:socio)
    end

    it "belongs to veiculo" do
      participacao = create(:participacao_socio)
      expect(participacao).to respond_to(:veiculo)
    end
  end

  describe "table name" do
    it "uses participacao_socios as table name" do
      expect(ParticipacaoSocio.table_name).to eq("participacao_socios")
    end
  end
end

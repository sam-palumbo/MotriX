require 'rails_helper'

RSpec.describe Locacao, type: :model do
  describe "validations" do
    let(:cliente) { create(:cliente) }
    let(:veiculo) { create(:veiculo) }

    it "is valid with valid attributes" do
      locacao = build(:locacao, cliente: cliente, veiculo: veiculo)
      expect(locacao).to be_valid
    end

    it "is invalid without a numero_contrato" do
      locacao = build(:locacao, cliente: cliente, veiculo: veiculo, numero_contrato: nil)
      expect(locacao).not_to be_valid
      expect(locacao.errors[:numero_contrato]).to include("can't be blank")
    end

    it "is invalid without a data_inicio" do
      locacao = build(:locacao, cliente: cliente, veiculo: veiculo, data_inicio: nil)
      expect(locacao).not_to be_valid
      expect(locacao.errors[:data_inicio]).to include("can't be blank")
    end

    it "is invalid without a data_prevista_fim" do
      locacao = build(:locacao, cliente: cliente, veiculo: veiculo, data_prevista_fim: nil)
      expect(locacao).not_to be_valid
      expect(locacao.errors[:data_prevista_fim]).to include("can't be blank")
    end

    it "is invalid without a valor_semanal" do
      locacao = build(:locacao, cliente: cliente, veiculo: veiculo, valor_semanal: nil)
      expect(locacao).not_to be_valid
      expect(locacao.errors[:valor_semanal]).to include("can't be blank")
    end

    it "is invalid without a status" do
      locacao = build(:locacao, cliente: cliente, veiculo: veiculo, status: nil)
      expect(locacao).not_to be_valid
      expect(locacao.errors[:status]).to include("can't be blank")
    end

    it "is invalid without a cliente" do
      locacao = build(:locacao, cliente: nil, veiculo: veiculo)
      expect(locacao).not_to be_valid
    end

    it "is invalid without a veiculo" do
      locacao = build(:locacao, cliente: cliente, veiculo: nil)
      expect(locacao).not_to be_valid
    end

    it "validates uniqueness of numero_contrato" do
      create(:locacao, numero_contrato: "LOC123456")
      locacao = build(:locacao, numero_contrato: "LOC123456")
      expect(locacao).not_to be_valid
      expect(locacao.errors[:numero_contrato]).to include("has already been taken")
    end

    it "validates data_prevista_fim is not before data_inicio" do
      locacao = build(:locacao,
        cliente: cliente,
        veiculo: veiculo,
        data_inicio: Date.new(2024, 1, 15),
        data_prevista_fim: Date.new(2024, 1, 10))
      expect(locacao).not_to be_valid
      expect(locacao.errors[:data_prevista_fim]).to include("deve ser maior ou igual a data de inicio")
    end

    it "validates data_fim is not before data_inicio" do
      locacao = build(:locacao,
        cliente: cliente,
        veiculo: veiculo,
        data_inicio: Date.new(2024, 1, 15),
        data_fim: Date.new(2024, 1, 10))
      expect(locacao).not_to be_valid
      expect(locacao.errors[:data_fim]).to include("deve ser maior ou igual a data de inicio")
    end

    it "allows data_prevista_fim equal to data_inicio" do
      locacao = build(:locacao,
        cliente: cliente,
        veiculo: veiculo,
        data_inicio: Date.new(2024, 1, 15),
        data_prevista_fim: Date.new(2024, 1, 15))
      expect(locacao).to be_valid
    end

    it "allows data_fim equal to data_inicio" do
      locacao = build(:locacao,
        cliente: cliente,
        veiculo: veiculo,
        data_inicio: Date.new(2024, 1, 15),
        data_fim: Date.new(2024, 1, 15))
      expect(locacao).to be_valid
    end
  end

  describe "associations" do
    let(:cliente) { create(:cliente) }
    let(:veiculo) { create(:veiculo) }

    it "belongs to cliente" do
      locacao = create(:locacao, cliente: cliente, veiculo: veiculo)
      expect(locacao).to respond_to(:cliente)
    end

    it "belongs to veiculo" do
      locacao = create(:locacao, cliente: cliente, veiculo: veiculo)
      expect(locacao).to respond_to(:veiculo)
    end

    it "has many eventos" do
      locacao = create(:locacao, cliente: cliente, veiculo: veiculo)
      expect(locacao).to respond_to(:eventos)
    end

    it "nullifies eventos on destroy" do
      locacao = create(:locacao, cliente: cliente, veiculo: veiculo)
      evento = create(:evento, :pagamento_semanal, locacao: locacao, status: "pago")

      expect { locacao.destroy }.to change { evento.reload.locacao_id }.to(nil)
    end
  end

  describe "status enum" do
    it "defines expected statuses" do
      expect(Locacao.statuses.keys).to include("ativa", "encerrada", "inadimplente", "cancelada")
    end

    it "has default status of ativa" do
      locacao = create(:locacao)
      expect(locacao.status).to eq("ativa")
    end
  end

  describe "#to_s" do
    it "returns the numero_contrato" do
      locacao = build(:locacao, numero_contrato: "LOC123456")
      expect(locacao.to_s).to eq("LOC123456")
    end
  end

  describe "#status_text" do
    it "returns humanized status" do
      locacao = build(:locacao, status: "ativa")
      expect(locacao.status_text).to eq("Ativa")
    end

    it "returns humanized status for encerrada" do
      locacao = build(:locacao, status: "encerrada")
      expect(locacao.status_text).to eq("Encerrada")
    end

    it "returns humanized status for inadimplente" do
      locacao = build(:locacao, status: "inadimplente")
      expect(locacao.status_text).to eq("Inadimplente")
    end

    it "returns humanized status for cancelada" do
      locacao = build(:locacao, status: "cancelada")
      expect(locacao.status_text).to eq("Cancelada")
    end
  end

  describe "custom validations" do
    let(:cliente) { create(:cliente) }
    let(:veiculo) { create(:veiculo) }

    context "data_prevista_fim_nao_antecede_inicio" do
      it "passes when data_inicio is blank" do
        locacao = build(:locacao, cliente: cliente, veiculo: veiculo, data_inicio: nil, data_prevista_fim: Date.today)
        expect(locacao).not_to be_valid # data_inicio is required
        expect(locacao.errors[:data_inicio]).to include("can't be blank")
      end

      it "passes when data_prevista_fim is blank" do
        locacao = build(:locacao, cliente: cliente, veiculo: veiculo, data_inicio: Date.today, data_prevista_fim: nil)
        expect(locacao).not_to be_valid # data_prevista_fim is required
        expect(locacao.errors[:data_prevista_fim]).to include("can't be blank")
      end

      it "passes when data_prevista_fim is after data_inicio" do
        locacao = build(:locacao,
          cliente: cliente,
          veiculo: veiculo,
          data_inicio: Date.today,
          data_prevista_fim: Date.today + 30.days)
        expect(locacao).to be_valid
      end
    end

    context "data_fim_nao_antecede_inicio" do
      it "passes when data_inicio is blank" do
        locacao = build(:locacao, cliente: cliente, veiculo: veiculo, data_inicio: nil, data_fim: Date.today)
        expect(locacao).not_to be_valid # data_inicio is required
        expect(locacao.errors[:data_inicio]).to include("can't be blank")
      end

      it "passes when data_fim is blank" do
        locacao = build(:locacao, cliente: cliente, veiculo: veiculo, data_inicio: Date.today, data_fim: nil)
        expect(locacao).to be_valid # data_fim is optional
      end

      it "passes when data_fim is after data_inicio" do
        locacao = build(:locacao,
          cliente: cliente,
          veiculo: veiculo,
          data_inicio: Date.today,
          data_fim: Date.today + 30.days)
        expect(locacao).to be_valid
      end
    end
  end
end

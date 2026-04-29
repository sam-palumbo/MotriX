require 'rails_helper'

RSpec.describe Cliente, type: :model do
  describe "validations" do
    it "is valid with valid attributes" do
      cliente = build(:cliente)
      expect(cliente).to be_valid
    end

    it "is invalid without a nome" do
      cliente = build(:cliente, nome: nil)
      expect(cliente).not_to be_valid
      expect(cliente.errors[:nome]).to include("can't be blank")
    end

    it "is invalid without a cpf" do
      cliente = build(:cliente, cpf: nil)
      expect(cliente).not_to be_valid
      expect(cliente.errors[:cpf]).to include("can't be blank")
    end

    it "is invalid without a status" do
      cliente = build(:cliente, status: nil)
      expect(cliente).not_to be_valid
      expect(cliente.errors[:status]).to include("can't be blank")
    end

    it "validates uniqueness of cpf" do
      create(:cliente, cpf: "12345678901")
      cliente = build(:cliente, cpf: "12345678901")
      expect(cliente).not_to be_valid
      expect(cliente.errors[:cpf]).to include("has already been taken")
    end
  end

  describe "associations" do
    it "has many locacoes" do
      cliente = create(:cliente)
      expect(cliente).to respond_to(:locacoes)
    end

    it "has many eventos" do
      cliente = create(:cliente)
      expect(cliente).to respond_to(:eventos)
    end

    it "nullifies dependent eventos on destroy" do
      cliente = create(:cliente)
      evento = create(:evento, :manutencao, cliente: cliente, veiculo: create(:veiculo), tipo_manutencao: "troca_oleo")
      
      expect { cliente.destroy }.to change { evento.reload.cliente_id }.to(nil)
    end

    it "restricts deletion if has locacoes" do
      cliente = create(:cliente)
      create(:locacao, cliente: cliente)
      
      expect { cliente.destroy }.to raise_error(ActiveRecord::DeleteRestrictionError)
    end
  end

  describe "status enum" do
    it "defines expected statuses" do
      expect(Cliente.statuses.keys).to include("ativo", "bloqueado", "inativo")
    end

    it "has default status of ativo" do
      cliente = create(:cliente)
      expect(cliente.status).to eq("ativo")
    end
  end

  describe "#to_s" do
    it "returns the nome" do
      cliente = build(:cliente, nome: "João Silva")
      expect(cliente.to_s).to eq("João Silva")
    end
  end

  describe "#status_text" do
    it "returns humanized status" do
      cliente = build(:cliente, status: "ativo")
      expect(cliente.status_text).to eq("Ativo")
    end

    it "returns humanized status for bloqueado" do
      cliente = build(:cliente, status: "bloqueado")
      expect(cliente.status_text).to eq("Bloqueado")
    end

    it "returns humanized status for inativo" do
      cliente = build(:cliente, status: "inativo")
      expect(cliente.status_text).to eq("Inativo")
    end
  end

  describe "#ativo?" do
    it "returns true when status is ativo" do
      cliente = build(:cliente, status: "ativo")
      expect(cliente.ativo?).to be true
    end

    it "returns false when status is bloqueado" do
      cliente = build(:cliente, status: "bloqueado")
      expect(cliente.ativo?).to be false
    end

    it "returns false when status is inativo" do
      cliente = build(:cliente, status: "inativo")
      expect(cliente.ativo?).to be false
    end
  end
end

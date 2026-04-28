require "rails_helper"

RSpec.describe Veiculo, type: :model do
  describe "associations" do
    it { should have_many(:locacoes).dependent(:restrict_with_exception) }
    it { should have_many(:eventos).dependent(:nullify) }
    it { should have_many(:participacao_socios).dependent(:destroy) }
    it { should have_many(:socios).through(:participacao_socios) }
    it { should have_many(:anexos).dependent(:destroy) }
  end

  describe "validations" do
    subject { build(:veiculo) }

    it { should validate_presence_of(:placa) }
    it { should validate_presence_of(:renavam) }
    it { should validate_presence_of(:chassi) }
    it { should validate_presence_of(:status) }

    describe "uniqueness validations" do
      it "validates placa uniqueness" do
        veiculo1 = create(:veiculo, placa: "ABC123")
        veiculo2 = build(:veiculo, placa: "ABC123")
        expect(veiculo2).not_to be_valid
        expect(veiculo2.errors[:placa].first).to match(/Translation missing/)
      end

      it "validates renavam uniqueness" do
        veiculo1 = create(:veiculo, renavam: "12345678901")
        veiculo2 = build(:veiculo, renavam: "12345678901", placa: "XYZ999", chassi: "DIFFERENT123")
        expect(veiculo2).not_to be_valid
        expect(veiculo2.errors[:renavam].first).to match(/Translation missing/)
      end

      it "validates chassi uniqueness" do
        veiculo1 = create(:veiculo, chassi: "1HGCM82633A123456")
        veiculo2 = build(:veiculo, chassi: "1HGCM82633A123456", placa: "XYZ999", renavam: "DIFFERENT123")
        expect(veiculo2).not_to be_valid
        expect(veiculo2.errors[:chassi].first).to match(/Translation missing/)
      end
    end
  end

  describe "enums" do
    it "defines status enum with correct values" do
      expect(Veiculo.statuses).to eq({
        "disponivel" => 0,
        "locado" => 1,
        "manutencao" => 2,
        "inativo" => 3
      })
    end

    describe "status scopes" do
      it "responds to disponivel scope" do
        expect(Veiculo).to respond_to(:disponivel)
      end

      it "responds to locado scope" do
        expect(Veiculo).to respond_to(:locado)
      end

      it "responds to manutencao scope" do
        expect(Veiculo).to respond_to(:manutencao)
      end

      it "responds to inativo scope" do
        expect(Veiculo).to respond_to(:inativo)
      end
    end

    describe "status predicates" do
      context "when status is disponivel" do
        let(:veiculo) { build(:veiculo, :disponivel) }

        it "returns true for disponivel?" do
          expect(veiculo.disponivel?).to be true
        end

        it "returns false for locado?" do
          expect(veiculo.locado?).to be false
        end

        it "returns false for manutencao?" do
          expect(veiculo.manutencao?).to be false
        end

        it "returns false for inativo?" do
          expect(veiculo.inativo?).to be false
        end
      end

      context "when status is locado" do
        let(:veiculo) { build(:veiculo, :locado) }

        it "returns false for disponivel?" do
          expect(veiculo.disponivel?).to be false
        end

        it "returns true for locado?" do
          expect(veiculo.locado?).to be true
        end

        it "returns false for manutencao?" do
          expect(veiculo.manutencao?).to be false
        end

        it "returns false for inativo?" do
          expect(veiculo.inativo?).to be false
        end
      end

      context "when status is manutencao" do
        let(:veiculo) { build(:veiculo, :manutencao) }

        it "returns false for disponivel?" do
          expect(veiculo.disponivel?).to be false
        end

        it "returns false for locado?" do
          expect(veiculo.locado?).to be false
        end

        it "returns true for manutencao?" do
          expect(veiculo.manutencao?).to be true
        end

        it "returns false for inativo?" do
          expect(veiculo.inativo?).to be false
        end
      end

      context "when status is inativo" do
        let(:veiculo) { build(:veiculo, :inativo) }

        it "returns false for disponivel?" do
          expect(veiculo.disponivel?).to be false
        end

        it "returns false for locado?" do
          expect(veiculo.locado?).to be false
        end

        it "returns false for manutencao?" do
          expect(veiculo.manutencao?).to be false
        end

        it "returns true for inativo?" do
          expect(veiculo.inativo?).to be true
        end
      end
    end
  end

  describe "#to_s" do
    context "when all fields are present" do
      let(:veiculo) { build(:veiculo, placa: "ABC123", marca: "Toyota", modelo: "Corolla") }

      it "returns formatted string with placa, marca and modelo" do
        expect(veiculo.to_s).to eq("ABC123 - Toyota - Corolla")
      end
    end

    context "when marca is nil" do
      let(:veiculo) { build(:veiculo, placa: "ABC123", marca: nil, modelo: "Corolla") }

      it "returns formatted string with placa and modelo" do
        expect(veiculo.to_s).to eq("ABC123 - Corolla")
      end
    end

    context "when modelo is nil" do
      let(:veiculo) { build(:veiculo, placa: "ABC123", marca: "Toyota", modelo: nil) }

      it "returns formatted string with placa and marca" do
        expect(veiculo.to_s).to eq("ABC123 - Toyota")
      end
    end

    context "when both marca and modelo are nil" do
      let(:veiculo) { build(:veiculo, placa: "ABC123", marca: nil, modelo: nil) }

      it "returns only placa" do
        expect(veiculo.to_s).to eq("ABC123")
      end
    end
  end

  describe "scopes" do
    describe ".disponivel" do
      let!(:veiculo_disponivel) { create(:veiculo, :disponivel) }
      let!(:veiculo_locado) { create(:veiculo, :locado) }
      let!(:veiculo_manutencao) { create(:veiculo, :manutencao) }
      let!(:veiculo_inativo) { create(:veiculo, :inativo) }

      it "returns only available vehicles" do
        expect(Veiculo.disponivel).to include(veiculo_disponivel)
        expect(Veiculo.disponivel).not_to include(veiculo_locado, veiculo_manutencao, veiculo_inativo)
      end
    end

    describe ".locado" do
      let!(:veiculo_disponivel) { create(:veiculo, :disponivel) }
      let!(:veiculo_locado) { create(:veiculo, :locado) }

      it "returns only rented vehicles" do
        expect(Veiculo.locado).to include(veiculo_locado)
        expect(Veiculo.locado).not_to include(veiculo_disponivel)
      end
    end

    describe ".manutencao" do
      let!(:veiculo_disponivel) { create(:veiculo, :disponivel) }
      let!(:veiculo_manutencao) { create(:veiculo, :manutencao) }

      it "returns only vehicles in maintenance" do
        expect(Veiculo.manutencao).to include(veiculo_manutencao)
        expect(Veiculo.manutencao).not_to include(veiculo_disponivel)
      end
    end

    describe ".inativo" do
      let!(:veiculo_disponivel) { create(:veiculo, :disponivel) }
      let!(:veiculo_inativo) { create(:veiculo, :inativo) }

      it "returns only inactive vehicles" do
        expect(Veiculo.inativo).to include(veiculo_inativo)
        expect(Veiculo.inativo).not_to include(veiculo_disponivel)
      end
    end
  end

  describe "factory" do
    it "creates a valid veiculo" do
      veiculo = create(:veiculo)
      expect(veiculo).to be_valid
    end

    it "creates a disponivel veiculo with :disponivel trait" do
      veiculo = create(:veiculo, :disponivel)
      expect(veiculo.status).to eq("disponivel")
      expect(veiculo.disponivel?).to be true
    end

    it "creates a locado veiculo with :locado trait" do
      veiculo = create(:veiculo, :locado)
      expect(veiculo.status).to eq("locado")
      expect(veiculo.locado?).to be true
    end

    it "creates a manutencao veiculo with :manutencao trait" do
      veiculo = create(:veiculo, :manutencao)
      expect(veiculo.status).to eq("manutencao")
      expect(veiculo.manutencao?).to be true
    end

    it "creates an inativo veiculo with :inativo trait" do
      veiculo = create(:veiculo, :inativo)
      expect(veiculo.status).to eq("inativo")
      expect(veiculo.inativo?).to be true
    end

    it "creates veiculo with unique placa" do
      veiculo1 = create(:veiculo, placa: "ABC123")
      veiculo2 = build(:veiculo, placa: "ABC123")
      expect(veiculo2).not_to be_valid
      expect(veiculo2.errors[:placa].first).to match(/Translation missing/)
    end

    it "creates veiculo with unique renavam" do
      renavam = "12345678901"
      veiculo1 = create(:veiculo, renavam: renavam)
      veiculo2 = build(:veiculo, renavam: renavam)
      expect(veiculo2).not_to be_valid
      expect(veiculo2.errors[:renavam].first).to match(/Translation missing/)
    end

    it "creates veiculo with unique chassi" do
      chassi = "1HGCM82633A123456"
      veiculo1 = create(:veiculo, chassi: chassi)
      veiculo2 = build(:veiculo, chassi: chassi)
      expect(veiculo2).not_to be_valid
      expect(veiculo2.errors[:chassi].first).to match(/Translation missing/)
    end
  end

  describe "dependent associations" do
    it "has correct dependent configurations" do
      expect(Veiculo.reflect_on_association(:locacoes).options[:dependent]).to eq(:restrict_with_exception)
      expect(Veiculo.reflect_on_association(:eventos).options[:dependent]).to eq(:nullify)
      expect(Veiculo.reflect_on_association(:participacao_socios).options[:dependent]).to eq(:destroy)
      expect(Veiculo.reflect_on_association(:anexos).options[:dependent]).to eq(:destroy)
    end
  end
end

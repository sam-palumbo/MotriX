require 'rails_helper'

RSpec.describe Usuario, type: :model do
  describe 'associations' do
    it { should have_many(:auditoria_logs).dependent(:restrict_with_exception) }
  end

  describe 'validations' do
    subject { build(:usuario) }

    it { should validate_presence_of(:cpf) }
    it { should validate_presence_of(:nome) }
    it { should validate_presence_of(:email) }
    context 'for new password users' do
      it 'requires password' do
        usuario = build(:usuario, password: nil, password_confirmation: nil)
        usuario.valid?
        expect(usuario.errors[:password]).to include("can't be blank")
      end
    end
    it { should validate_presence_of(:perfil) }

    it { should validate_uniqueness_of(:cpf).case_insensitive }
    it { should validate_uniqueness_of(:email).case_insensitive }
  end

  describe 'enums' do
    it 'defines perfil enum with correct values' do
      expect(Usuario.perfils).to eq({
        'admin' => 0,
        'operador' => 1,
        'socio' => 2
      })
    end

    describe 'perfil scopes' do
      it 'responds to admin scope' do
        expect(Usuario).to respond_to(:admin)
      end

      it 'responds to operador scope' do
        expect(Usuario).to respond_to(:operador)
      end

      it 'responds to socio scope' do
        expect(Usuario).to respond_to(:socio)
      end
    end

    describe 'perfil predicates' do
      context 'when perfil is admin' do
        let(:usuario) { build(:usuario, :admin) }

        it 'returns true for perfil_admin?' do
          expect(usuario.perfil_admin?).to be true
        end

        it 'returns false for perfil_operador?' do
          expect(usuario.perfil_operador?).to be false
        end

        it 'returns false for perfil_socio?' do
          expect(usuario.perfil_socio?).to be false
        end
      end

      context 'when perfil is operador' do
        let(:usuario) { build(:usuario, :operador) }

        it 'returns false for perfil_admin?' do
          expect(usuario.perfil_admin?).to be false
        end

        it 'returns true for perfil_operador?' do
          expect(usuario.perfil_operador?).to be true
        end

        it 'returns false for perfil_socio?' do
          expect(usuario.perfil_socio?).to be false
        end
      end

      context 'when perfil is socio' do
        let(:usuario) { build(:usuario, :socio) }

        it 'returns false for perfil_admin?' do
          expect(usuario.perfil_admin?).to be false
        end

        it 'returns false for perfil_operador?' do
          expect(usuario.perfil_operador?).to be false
        end

        it 'returns true for perfil_socio?' do
          expect(usuario.perfil_socio?).to be true
        end
      end
    end
  end

  describe 'scopes' do
    describe '.ativos' do
      let!(:usuario_ativo) { create(:usuario, ativo: true) }
      let!(:usuario_inativo) { create(:usuario, ativo: false) }

      it 'returns only active usuarios' do
        expect(Usuario.ativos).to include(usuario_ativo)
        expect(Usuario.ativos).not_to include(usuario_inativo)
      end
    end
  end

  describe '#to_s' do
    it 'returns the nome' do
      usuario = build(:usuario, nome: 'João Silva')
      expect(usuario.to_s).to eq('João Silva')
    end
  end

  describe '#perfil_text' do
    context 'when perfil is admin' do
      let(:usuario) { build(:usuario, :admin) }

      it 'returns "Administrador"' do
        expect(usuario.perfil_text).to eq('Administrador')
      end
    end

    context 'when perfil is operador' do
      let(:usuario) { build(:usuario, :operador) }

      it 'returns "Operador"' do
        expect(usuario.perfil_text).to eq('Operador')
      end
    end

    context 'when perfil is socio' do
      let(:usuario) { build(:usuario, :socio) }

      it 'returns "Sócio"' do
        expect(usuario.perfil_text).to eq('Sócio')
      end
    end
  end

  describe '#ativo?' do
    context 'when ativo is true' do
      let(:usuario) { build(:usuario, ativo: true) }

      it 'returns true' do
        expect(usuario.ativo?).to be true
      end
    end

    context 'when ativo is false' do
      let(:usuario) { build(:usuario, ativo: false) }

      it 'returns false' do
        expect(usuario.ativo?).to be false
      end
    end
  end

  describe 'password' do
    it 'has_secure_password' do
      usuario = build(:usuario, password: 'password123')
      expect(usuario).to respond_to(:password_digest)
    end

    it 'authenticates with correct password' do
      usuario = create(:usuario, password: 'password123')
      expect(usuario.authenticate('password123')).to eq(usuario)
    end

    it 'does not authenticate with incorrect password' do
      usuario = create(:usuario, password: 'password123')
      expect(usuario.authenticate('wrongpassword')).to be false
    end
  end

  describe 'factory' do
    it 'creates a valid usuario' do
      usuario = create(:usuario)
      expect(usuario).to be_valid
    end

    it 'creates an admin usuario with :admin trait' do
      usuario = create(:usuario, :admin)
      expect(usuario.perfil).to eq('admin')
      expect(usuario.perfil_admin?).to be true
    end

    it 'creates an operador usuario with :operador trait' do
      usuario = create(:usuario, :operador)
      expect(usuario.perfil).to eq('operador')
      expect(usuario.perfil_operador?).to be true
    end

    it 'creates a socio usuario with :socio trait' do
      usuario = create(:usuario, :socio)
      expect(usuario.perfil).to eq('socio')
      expect(usuario.perfil_socio?).to be true
    end

    it 'creates an inactive usuario with :inativo trait' do
      usuario = create(:usuario, :inativo)
      expect(usuario.ativo).to be false
    end
  end
end

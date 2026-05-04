require 'rails_helper'

RSpec.describe EventoFilenameGenerator do
  describe '.generate_filename' do
    context 'when all components are present' do
      it 'generates complete filename with all sections' do
        veiculo = double('Veiculo', placa: 'ABC1234')
        cliente = double('Cliente', nome: 'João Silva')
        evento_date = Date.new(2024, 5, 4)
        document_type = 'contrato'
        
        result = described_class.generate_filename(
          veiculo: veiculo,
          cliente: cliente,
          document_type: document_type,
          evento_date: evento_date
        )
        
        expect(result).to eq('ABC1234_Joao_Silva_contrato_20240504')
      end
    end

    context 'when veiculo is missing' do
      it 'generates filename with veiculo_indisponivel placeholder' do
        veiculo = nil
        cliente = double('Cliente', nome: 'Maria Santos')
        evento_date = Date.new(2024, 5, 4)
        document_type = 'recibo'
        
        result = described_class.generate_filename(
          veiculo: veiculo,
          cliente: cliente,
          document_type: document_type,
          evento_date: evento_date
        )
        
        expect(result).to eq('veiculo_indisponivel_Maria_Santos_recibo_20240504')
      end
    end

    context 'when cliente is missing' do
      it 'generates filename with cliente_indisponivel placeholder' do
        veiculo = double('Veiculo', placa: 'XYZ5678')
        cliente = nil
        evento_date = Date.new(2024, 5, 4)
        document_type = 'nota_fiscal'
        
        result = described_class.generate_filename(
          veiculo: veiculo,
          cliente: cliente,
          document_type: document_type,
          evento_date: evento_date
        )
        
        expect(result).to eq('XYZ5678_cliente_indisponivel_nota_fiscal_20240504')
      end
    end

    context 'when both veiculo and cliente are missing' do
      it 'generates filename with both placeholders' do
        veiculo = nil
        cliente = nil
        evento_date = Date.new(2024, 5, 4)
        document_type = 'comprovante'
        
        result = described_class.generate_filename(
          veiculo: veiculo,
          cliente: cliente,
          document_type: document_type,
          evento_date: evento_date
        )
        
        expect(result).to eq('veiculo_indisponivel_cliente_indisponivel_comprovante_20240504')
      end
    end

    context 'when names contain special characters' do
      it 'sanitizes special characters' do
        veiculo = double('Veiculo', placa: 'ABC-1234')
        cliente = double('Cliente', nome: 'José Álvarez (Filho)')
        evento_date = Date.new(2024, 5, 4)
        document_type = 'documento_oficial'
        
        result = described_class.generate_filename(
          veiculo: veiculo,
          cliente: cliente,
          document_type: document_type,
          evento_date: evento_date
        )
        
        expect(result).to eq('ABC_1234_Jose_Alvarez_Filho_documento_oficial_20240504')
      end
    end

    context 'when names have multiple spaces and empty strings' do
      it 'normalizes spaces and handles empty strings' do
        veiculo = double('Veiculo', placa: '  ABC1234  ')
        cliente = double('Cliente', nome: '  ')
        evento_date = Date.new(2024, 5, 4)
        document_type = '  relatorio  '
        
        result = described_class.generate_filename(
          veiculo: veiculo,
          cliente: cliente,
          document_type: document_type,
          evento_date: evento_date
        )
        
        expect(result).to eq('ABC1234_cliente_indisponivel_relatorio_20240504')
      end
    end

    context 'when document type is nil' do
      it 'raises an error' do
        veiculo = double('Veiculo', placa: 'ABC1234')
        cliente = double('Cliente', nome: 'Test Client')
        evento_date = Date.new(2024, 5, 4)
        document_type = nil
        
        expect {
          described_class.generate_filename(
            veiculo: veiculo,
            cliente: cliente,
            document_type: document_type,
            evento_date: evento_date
          )
        }.to raise_error('Document type cannot be nil')
      end
    end

    context 'when document type is empty string' do
      it 'raises an error' do
        veiculo = double('Veiculo', placa: 'ABC1234')
        cliente = double('Cliente', nome: 'Test Client')
        evento_date = Date.new(2024, 5, 4)
        document_type = ''
        
        expect {
          described_class.generate_filename(
            veiculo: veiculo,
            cliente: cliente,
            document_type: document_type,
            evento_date: evento_date
          )
        }.to raise_error('Document type cannot be empty')
      end
    end
  end
end

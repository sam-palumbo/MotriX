require 'rails_helper'

RSpec.describe EventoUploadProcessor do
  let(:veiculo) { double('Veiculo', id: 1, placa: 'ABC1234') }
  let(:cliente) { double('Cliente', id: 1, nome: 'João Silva') }
  let(:evento_date) { Date.new(2024, 5, 4) }
  let(:upload_file) { double('UploadedFile', original_filename: 'test.pdf', content_type: 'application/pdf', size: 1024) }
  
  describe '.process_uploads' do
    context 'with valid uploads' do
      it 'processes multiple files with correct filenames' do
        uploads = [
          { file: upload_file, document_type: 'contrato' },
          { file: upload_file, document_type: 'recibo' }
        ]
        
        result = described_class.process_uploads(
          uploads: uploads,
          veiculo: veiculo,
          cliente: cliente,
          evento_date: evento_date
        )
        
        expect(result.success).to be true
        expect(result.processed_files.size).to eq(2)
        expect(result.processed_files.first[:generated_filename]).to eq('ABC1234_Joao_Silva_contrato_20240504.pdf')
        expect(result.processed_files.last[:generated_filename]).to eq('ABC1234_Joao_Silva_recibo_20240504.pdf')
      end
    end

    context 'when document type is missing' do
      it 'returns validation error' do
        uploads = [{ file: upload_file, document_type: '' }]
        
        expect {
          described_class.process_uploads(
            uploads: uploads,
            veiculo: veiculo,
            cliente: cliente,
            evento_date: evento_date
          )
        }.to raise_error('Document type is required')
      end
    end

    context 'when file type is invalid' do
      let(:invalid_file) { double('UploadedFile', content_type: 'application/octet-stream', size: 1024) }
      
      it 'returns validation error' do
        uploads = [{ file: invalid_file, document_type: 'documento_oficial' }]
        
        expect {
          described_class.process_uploads(
            uploads: uploads,
            veiculo: veiculo,
            cliente: cliente,
            evento_date: evento_date
          )
        }.to raise_error('File type not allowed')
      end
    end

    context 'when veiculo is nil' do
      it 'uses veiculo_indisponivel placeholder' do
        uploads = [{ file: upload_file, document_type: 'comprovante' }]
        
        result = described_class.process_uploads(
          uploads: uploads,
          veiculo: nil,
          cliente: cliente,
          evento_date: evento_date
        )
        
        expect(result.processed_files.first[:generated_filename]).to eq('veiculo_indisponivel_Joao_Silva_comprovante_20240504.pdf')
      end
    end

    context 'when cliente is nil' do
      it 'uses cliente_indisponivel placeholder' do
        uploads = [{ file: upload_file, document_type: 'relatorio' }]
        
        result = described_class.process_uploads(
          uploads: uploads,
          veiculo: veiculo,
          cliente: nil,
          evento_date: evento_date
        )
        
        expect(result.processed_files.first[:generated_filename]).to eq('ABC1234_cliente_indisponivel_relatorio_20240504.pdf')
      end
    end
  end
end

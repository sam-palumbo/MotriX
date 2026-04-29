require_relative '../config/environment'
require 'roo'

class WorkingImport
  def initialize(file_path)
    @file_path = file_path
  end

  def import_events
    puts "Working import of events from: #{@file_path}"
    
    begin
      spreadsheet = Roo::Spreadsheet.open(@file_path)
      worksheet = spreadsheet.sheets.first
      sheet = spreadsheet.sheet(worksheet)
      
      puts "Processing #{sheet.last_row - 1} events..."
      
      imported = 0
      skipped = 0
      
      (2..sheet.last_row).each do |row|
        begin
          # Extract data
          evento_data = {
            id_evento: sheet.cell(row, 1),
            data: sheet.cell(row, 2),
            tipo_evento: sheet.cell(row, 3),
            fluxo: sheet.cell(row, 4),
            placa: sheet.cell(row, 6),
            nome_cliente: sheet.cell(row, 8),
            valor_pago: sheet.cell(row, 11),
            responsavel_pagamento: sheet.cell(row, 12),
            status: sheet.cell(row, 13),
            descricao: sheet.cell(row, 16)
          }
          
          # Skip if no value
          if evento_data[:valor_pago].nil? || evento_data[:valor_pago] == 0
            skipped += 1
            next
          end
          
          # Map to database values
          tipo_evento_db = map_tipo_evento(evento_data[:tipo_evento])
          fluxo_db = evento_data[:fluxo]&.downcase == 'entrada' ? 'entrada' : 'saida'
          
          # Find vehicle ID
          veiculo_id = nil
          if evento_data[:placa]
            veiculo = Veiculo.find_by(placa: evento_data[:placa].to_s.strip)
            veiculo_id = veiculo.id if veiculo
          end
          
          # Find client ID
          cliente_id = nil
          if evento_data[:nome_cliente]
            cliente = Cliente.find_by("nome ILIKE ?", "%#{evento_data[:nome_cliente]}%")
            cliente_id = cliente.id if cliente
          end
          
          # Use raw SQL without created_by/updated_by
          result = ActiveRecord::Base.connection.execute(
            "INSERT INTO eventos (tipo_evento, fluxo, valor, responsavel, data_evento, descricao, status, created_at, updated_at, veiculo_id, cliente_id) 
             VALUES ($1, $2, $3, $4, $5, $6, $7, $8, $9, $10, $11) RETURNING id",
            [tipo_evento_db, fluxo_db, evento_data[:valor_pago] || 0, evento_data[:responsavel_pagamento] || 'Sistema', evento_data[:data] || Date.current, evento_data[:descricao], 'pago', Time.current, Time.current, veiculo_id, cliente_id]
          )
          
          imported += 1
          puts "✓ #{imported}: #{tipo_evento_db} - R$ #{evento_data[:valor_pago]}"
          
        rescue => e
          skipped += 1
          puts "✗ Row #{row} error: #{e.message}"
        end
      end
      
      puts "\nImport completed:"
      puts "Successfully imported: #{imported} events"
      puts "Skipped: #{skipped} events"
      
    rescue => e
      puts "Fatal error: #{e.message}"
      puts e.backtrace
    end
  end
  
  private
  
  def map_tipo_evento(tipo)
    case tipo&.to_s&.downcase
    when 'aquisicao_veiculo'
      'aquisicao_veiculo'
    when 'pagamento_semanal'
      'pagamento_semanal'
    when 'manutencao'
      'manutencao'
    when 'gasto_empresa'
      'gasto_empresa'
    when 'retirada'
      'retirada'
    when 'devolucao'
      'devolucao'
    when 'saida_frota'
      'saida_frota'
    else
      'gasto_empresa'
    end
  end
end

# Run the import
if __FILE__ == $0
  file_path = ARGV[0] || 'c:\Projects\motrix\4A_Locadora_com_LOG Final - 26-04-2026 14_49 (1).xlsx'
  importer = WorkingImport.new(file_path)
  importer.import_events
end

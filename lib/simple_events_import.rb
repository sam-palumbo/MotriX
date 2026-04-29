require_relative '../config/environment'
require 'roo'

class SimpleEventsImport
  def initialize(file_path)
    @file_path = file_path
  end

  def import
    puts "Importing events from: #{@file_path}"
    
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
            descricao: sheet.cell(row, 16),
            obs: sheet.cell(row, 17)
          }
          
          # Skip if no plate or value
          if evento_data[:placa].nil? && evento_data[:nome_cliente].nil?
            skipped += 1
            next
          end
          
          # Create event with minimal required fields
          evento = Evento.new(
            tipo_evento: map_tipo_evento(evento_data[:tipo_evento]),
            fluxo: evento_data[:fluxo]&.downcase == 'entrada' ? 'entrada' : 'saida',
            valor: evento_data[:valor_pago] || 0,
            data_evento: evento_data[:data] || Date.current,
            responsavel: evento_data[:responsavel_pagamento] || 'Sistema',
            descricao: evento_data[:descricao],
            status: 'pago'
          )
          
          # Try to find vehicle
          if evento_data[:placa]
            veiculo = Veiculo.find_by(placa: evento_data[:placa].to_s.strip)
            evento.veiculo_id = veiculo.id if veiculo
          end
          
          # Try to find client
          if evento_data[:nome_cliente]
            cliente = Cliente.find_by("nome ILIKE ?", "%#{evento_data[:nome_cliente]}%")
            evento.cliente_id = cliente.id if cliente
          end
          
          if evento.save
            imported += 1
            puts "✓ #{imported}: #{evento.tipo_evento} - R$ #{evento.valor}"
          else
            skipped += 1
            puts "✗ Error: #{evento.errors.full_messages.join(', ')}"
          end
          
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
      'gasto_empresa' # Default to gasto_empresa for unknown types
    end
  end
end

# Run the import
if __FILE__ == $0
  file_path = ARGV[0] || 'c:\Projects\motrix\4A_Locadora_com_LOG Final - 26-04-2026 14_49 (1).xlsx'
  importer = SimpleEventsImport.new(file_path)
  importer.import
end

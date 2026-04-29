require_relative '../config/environment'
require 'roo'

class FinancialEventsParser
  def initialize(file_path)
    @file_path = file_path
  end

  def import_events
    puts "Importing financial events from: #{@file_path}"
    
    begin
      spreadsheet = Roo::Spreadsheet.open(@file_path)
      worksheet = spreadsheet.sheets.first
      sheet = spreadsheet.sheet(worksheet)
      
      puts "Worksheet: #{worksheet}"
      puts "Total rows: #{sheet.last_row}"
      
      imported = 0
      skipped = 0
      
      (2..sheet.last_row).each do |row|
        begin
          # Extract data from spreadsheet
          evento_data = {
            id_evento: sheet.cell(row, 1),
            data: sheet.cell(row, 2),
            tipo_evento: sheet.cell(row, 3),
            fluxo: sheet.cell(row, 4),
            id_veiculo: sheet.cell(row, 5),
            placa: sheet.cell(row, 6),
            id_cliente: sheet.cell(row, 7),
            nome_cliente: sheet.cell(row, 8),
            valor_referencia: sheet.cell(row, 9),
            desconto_abatimento: sheet.cell(row, 10),
            valor_pago: sheet.cell(row, 11),
            responsavel_pagamento: sheet.cell(row, 12),
            status: sheet.cell(row, 13),
            semana_ref: sheet.cell(row, 14),
            km_veiculo: sheet.cell(row, 15),
            descricao: sheet.cell(row, 16),
            obs: sheet.cell(row, 17),
            tipo_manutencao: sheet.cell(row, 18)
          }
          
          # Find associated records
          veiculo = find_or_create_veiculo(evento_data)
          cliente = find_or_create_cliente(evento_data)
          
          # Create event
          evento = Evento.new(
            tipo_evento: map_tipo_evento(evento_data[:tipo_evento]),
            fluxo: evento_data[:fluxo]&.downcase == 'entrada' ? 'entrada' : 'saida',
            valor: evento_data[:valor_pago] || evento_data[:valor_referencia] || 0,
            data_evento: evento_data[:data],
            responsavel: evento_data[:responsavel_pagamento],
            descricao: build_descricao(evento_data),
            observacoes: evento_data[:obs],
            status: map_status(evento_data[:status]),
            veiculo_id: veiculo&.id,
            cliente_id: cliente&.id,
            tipo_manutencao: evento_data[:tipo_manutencao],
            km_veiculo: evento_data[:km_veiculo]&.to_i,
            valor_referencia: evento_data[:valor_referencia],
            desconto_abatimento: evento_data[:desconto_abatimento]
          )
          
          if evento.save
            imported += 1
            puts "✓ Imported: #{evento.tipo_evento} - #{evento.fluxo} R$ #{evento.valor}"
          else
            skipped += 1
            puts "✗ Skipped row #{row}: #{evento.errors.full_messages.join(', ')}"
          end
          
        rescue => e
          skipped += 1
          puts "✗ Error row #{row}: #{e.message}"
        end
      end
      
      puts "\nImport completed:"
      puts "Successfully imported: #{imported} events"
      puts "Skipped: #{skipped} events"
      
    rescue => e
      puts "Error processing spreadsheet: #{e.message}"
      puts e.backtrace
    end
  end
  
  private
  
  def find_or_create_veiculo(data)
    return nil unless data[:placa]
    
    veiculo = Veiculo.find_by(placa: data[:placa].to_s.strip)
    
    unless veiculo
      veiculo = Veiculo.create!(
        placa: data[:placa].to_s.strip,
        marca: 'Desconhecida',
        modelo: 'Desconhecido',
        status: 'disponivel'
      )
      puts "Created new vehicle: #{veiculo.placa}"
    end
    
    veiculo
  end
  
  def find_or_create_cliente(data)
    return nil unless data[:id_cliente] || data[:nome_cliente]
    
    # Try to find by CPF first
    cliente = nil
    if data[:id_cliente]
      cliente = Cliente.find_by(cpf: data[:id_cliente].to_s.strip)
    end
    
    # If not found, try by name
    unless cliente
      if data[:nome_cliente]
        cliente = Cliente.find_by(nome: data[:nome_cliente].to_s.strip)
      end
    end
    
    # Create new client if not found
    unless cliente
      cliente = Cliente.create!(
        nome: data[:nome_cliente]&.to_s&.strip || 'Cliente Sem Nome',
        cpf: data[:id_cliente]&.to_s&.strip,
        status: 'ativo'
      )
      puts "Created new client: #{cliente.nome}"
    end
    
    cliente
  end
  
  def map_tipo_evento(tipo)
    case tipo&.to_s&.downcase
    when 'aquisicao_veiculo'
      'aquisicao'
    when 'pagamento_semanal'
      'pagamento'
    when 'manutencao'
      'manutencao'
    when 'seguro'
      'seguro'
    when 'imposto'
      'imposto'
    when 'outros'
      'outro'
    else
      'outro'
    end
  end
  
  def map_status(status)
    case status&.to_s&.downcase
    when 'pago'
      'concluido'
    when 'pendente'
      'pendente'
    when 'cancelado'
      'cancelado'
    else
      'concluido'
    end
  end
  
  def build_descricao(data)
    parts = []
    parts << data[:descricao] if data[:descricao]&.to_s&.strip&.length > 0
    parts << "Semana #{data[:semana_ref]}" if data[:semana_ref]
    parts << "KM: #{data[:km_veiculo]}" if data[:km_veiculo]
    parts.join(' - ')
  end
end

# Run the parser
if __FILE__ == $0
  file_path = ARGV[0] || 'c:\Projects\motrix\4A_Locadora_com_LOG Final - 26-04-2026 14_49 (1).xlsx'
  parser = FinancialEventsParser.new(file_path)
  parser.import_events
end

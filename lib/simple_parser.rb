require_relative '../config/environment'
require 'roo'

class SimpleParser
  def initialize(file_path)
    @file_path = file_path
  end

  def examine_spreadsheet
    puts "Examining spreadsheet: #{@file_path}"
    
    begin
      spreadsheet = Roo::Spreadsheet.open(@file_path)
      worksheet = spreadsheet.sheets.first
      sheet = spreadsheet.sheet(worksheet)
      
      puts "Worksheet: #{worksheet}"
      puts "Total rows: #{sheet.last_row}"
      puts "Total columns: #{sheet.last_column}"
      
      # Get headers
      headers = []
      (1..sheet.last_column).each do |col|
        headers << sheet.cell(1, col)
      end
      
      puts "\nHeaders:"
      headers.each_with_index do |header, i|
        puts "  #{i+1}. #{header}"
      end
      
      # Show first 3 rows of actual data
      puts "\nFirst 3 rows of data:"
      (2..[4, sheet.last_row].min).each do |row|
        puts "Row #{row}:"
        headers.each_with_index do |header, col_index|
          value = sheet.cell(row, col_index + 1)
          puts "  #{header}: #{value}"
        end
        puts ""
      end
      
      return headers, sheet
      
    rescue => e
      puts "Error: #{e.message}"
      puts e.backtrace
      return nil, nil
    end
  end
  
  def import_vehicles(sheet, headers)
    puts "\nImporting vehicles..."
    
    imported = 0
    skipped = 0
    
    (2..sheet.last_row).each do |row|
      begin
        # Extract data from spreadsheet
        row_data = {}
        headers.each_with_index do |header, index|
          row_data[header] = sheet.cell(row, index + 1)
        end
        
        # Map to Veiculo model fields
        veiculo = Veiculo.new(
          placa: row_data['Placa']&.to_s&.strip,
          marca: row_data['Marca']&.to_s&.strip,
          modelo: row_data['Modelo']&.to_s&.strip,
          ano: row_data['Ano']&.to_i,
          cor: row_data['Cor']&.to_s&.strip,
          renavam: row_data['RENAVAM']&.to_s&.strip,
          chassi: row_data['Chassi']&.to_s&.strip,
          status: 'disponivel'
        )
        
        if veiculo.save
          imported += 1
          puts "✓ Imported: #{veiculo.placa} - #{veiculo.marca} #{veiculo.modelo}"
        else
          skipped += 1
          puts "✗ Skipped row #{row}: #{veiculo.errors.full_messages.join(', ')}"
        end
        
      rescue => e
        skipped += 1
        puts "✗ Error row #{row}: #{e.message}"
      end
    end
    
    puts "\nVehicle import completed:"
    puts "Imported: #{imported}"
    puts "Skipped: #{skipped}"
  end
end

# Run the parser
if __FILE__ == $0
  file_path = ARGV[0] || 'c:\Projects\motrix\4A_Locadora_com_LOG Final - 26-04-2026 14_49 (1).xlsx'
  parser = SimpleParser.new(file_path)
  
  headers, sheet = parser.examine_spreadsheet
  
  if headers && sheet
    puts "\nPress Enter to continue with import..."
    gets
    
    parser.import_vehicles(sheet, headers)
  end
end

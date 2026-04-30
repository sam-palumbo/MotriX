require_relative "../config/environment"
require "roo"
require "csv"

class SpreadsheetParser
  def initialize(file_path)
    @file_path = file_path
  end

  def parse_and_import
    puts "Parsing spreadsheet: #{@file_path}"

    begin
      spreadsheet = Roo::Spreadsheet.open(@file_path)

      # Get the first worksheet
      worksheet = spreadsheet.sheets.first
      sheet = spreadsheet.sheet(worksheet)

      puts "Worksheet name: #{worksheet}"
      puts "Total rows: #{sheet.last_row}"

      # Print headers
      headers = []
      (1..sheet.last_column).each do |col|
        headers << sheet.cell(1, col)
      end

      puts "Headers: #{headers.inspect}"

      # Print first few rows of data
      puts "\nFirst 5 rows of data:"
      (2..[ 6, sheet.last_row ].min).each do |row|
        row_data = []
        (1..sheet.last_column).each do |col|
          row_data << sheet.cell(row, col)
        end
        puts "Row #{row}: #{row_data.inspect}"
      end

      # Determine which model to import based on headers
      model_type = determine_model_type(headers)
      puts "\nDetected model type: #{model_type}"

      # Import data
      import_data(sheet, headers, model_type)

    rescue => e
      puts "Error parsing spreadsheet: #{e.message}"
      puts e.backtrace
    end
  end

  private

  def determine_model_type(headers)
    headers_str = headers.map(&:to_s).map(&:downcase).join(" ")

    if headers_str.include?("placa") || headers_str.include?("veiculo") || headers_str.include?("renavam")
      "veiculo"
    elsif headers_str.include?("cliente") || headers_str.include?("cpf") || headers_str.include?("nome")
      "cliente"
    elsif headers_str.include?("locacao") || headers_str.include?("contrato") || headers_str.include?("aluguel")
      "locacao"
    elsif headers_str.include?("evento") || headers_str.include?("financeiro") || headers_str.include?("valor")
      "evento"
    else
      "unknown"
    end
  end

  def import_data(sheet, headers, model_type)
    puts "\nImporting data as #{model_type}..."

    imported_count = 0
    skipped_count = 0

    (2..sheet.last_row).each do |row|
      begin
        row_data = {}
        headers.each_with_index do |header, index|
          row_data[header] = sheet.cell(row, index + 1)
        end

        case model_type
        when "veiculo"
          import_veiculo(row_data)
        when "cliente"
          import_cliente(row_data)
        when "locacao"
          import_locacao(row_data)
        when "evento"
          import_evento(row_data)
        else
          puts "Unknown model type, skipping row #{row}"
          skipped_count += 1
          next
        end

        imported_count += 1
        puts "Imported row #{row}/#{sheet.last_row}"

      rescue => e
        puts "Error importing row #{row}: #{e.message}"
        skipped_count += 1
      end
    end

    puts "\nImport completed:"
    puts "Successfully imported: #{imported_count} records"
    puts "Skipped: #{skipped_count} records"
  end

  def import_veiculo(data)
    # Map spreadsheet columns to Veiculo model
    veiculo_params = {
      placa: data["Placa"] || data["placa"],
      marca: data["Marca"] || data["marca"],
      modelo: data["Modelo"] || data["modelo"],
      ano: data["Ano"] || data["ano"],
      cor: data["Cor"] || data["cor"],
      renavam: data["RENAVAM"] || data["renavam"],
      chassi: data["Chassi"] || data["chassi"],
      status: "disponivel" # Default status
    }.compact

    Veiculo.create!(veiculo_params)
  end

  def import_cliente(data)
    # Map spreadsheet columns to Cliente model
    cliente_params = {
      nome: data["Nome"] || data["nome"],
      cpf: data["CPF"] || data["cpf"],
      telefone: data["Telefone"] || data["telefone"],
      email: data["Email"] || data["email"],
      endereco: data["Endereço"] || data["endereco"],
      status: "ativo" # Default status
    }.compact

    Cliente.create!(cliente_params)
  end

  def import_locacao(data)
    # Map spreadsheet columns to Locacao model
    # Need to find associated cliente and veiculo
    cliente = Cliente.find_by(nome: data["Cliente"] || data["cliente"])
    veiculo = Veiculo.find_by(placa: data["Veículo"] || data["veiculo"] || data["Placa"] || data["placa"])

    locacao_params = {
      cliente_id: cliente&.id,
      veiculo_id: veiculo&.id,
      data_inicio: data["Data Início"] || data["data_inicio"],
      data_prevista_fim: data["Data Prevista Fim"] || data["data_prevista_fim"],
      valor: data["Valor"] || data["valor"],
      status: "ativa" # Default status
    }.compact

    Locacao.create!(locacao_params)
  end

  def import_evento(data)
    # Map spreadsheet columns to Evento model
    evento_params = {
      tipo_evento: data["Tipo"] || data["tipo"] || "outro",
      descricao: data["Descrição"] || data["descricao"],
      valor: data["Valor"] || data["valor"],
      data_evento: data["Data"] || data["data"] || Date.current,
      fluxo: (data["Valor"] || data["valor"] || 0) > 0 ? "entrada" : "saida",
      status: "concluido" # Default status
    }.compact

    Evento.create!(evento_params)
  end
end

# Usage
if __FILE__ == $0
  file_path = ARGV[0] || 'c:\Projects\motrix\4A_Locadora_com_LOG Final - 26-04-2026 14_49 (1).xlsx'
  parser = SpreadsheetParser.new(file_path)
  parser.parse_and_import
end

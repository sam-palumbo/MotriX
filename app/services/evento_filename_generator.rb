class EventoFilenameGenerator
  # Character mapping for internationalization and special character normalization
  CHARACTER_MAPPING = {
    /[áàâãä]/ => 'a', /[ÁÀÂÃÄ]/ => 'A',
    /[éèêë]/ => 'e', /[ÉÈÊË]/ => 'E',
    /[íìîï]/ => 'i', /[ÍÌÎÏ]/ => 'I',
    /[óòôõö]/ => 'o', /[ÓÒÔÕÖ]/ => 'O',
    /[úùûü]/ => 'u', /[ÚÙÛÜ]/ => 'U',
    /[ñ]/ => 'n', /[Ñ]/ => 'N',
    /[ç]/ => 'c', /[Ç]/ => 'C',
    /[-]/ => '_' # Replace hyphens with underscores
  }.freeze

  class << self
    # Generates a standardized filename for evento uploads
    # @param veiculo [Veiculo, nil] - Vehicle object with placa attribute
    # @param cliente [Cliente, nil] - Client object with nome attribute  
    # @param document_type [String] - Type of document (required)
    # @param evento_date [Date] - Date of the evento
    # @return [String] - Formatted filename: veiculo_cliente_document_type_yyyymmdd
    def generate_filename(veiculo:, cliente:, document_type:, evento_date:)
      validate_document_type!(document_type)
      
      veiculo_name = extract_veiculo_name(veiculo)
      cliente_name = extract_cliente_name(cliente)
      sanitized_document_type = sanitize_name(document_type)
      formatted_date = format_date(evento_date)
      
      [
        sanitize_name(veiculo_name),
        sanitize_name(cliente_name),
        sanitized_document_type,
        formatted_date
      ].compact.join('_')
    end

    private

    def validate_document_type!(document_type)
      raise 'Document type cannot be nil' if document_type.nil?
      raise 'Document type cannot be empty' if document_type.strip.empty?
    end

    def extract_veiculo_name(veiculo)
      return 'veiculo_indisponivel' if veiculo.nil?
      
      placa = veiculo.respond_to?(:placa) ? veiculo.placa : 'veiculo_indisponivel'
      placa.to_s.strip.empty? ? 'veiculo_indisponivel' : placa.to_s.strip
    end

    def extract_cliente_name(cliente)
      return 'cliente_indisponivel' if cliente.nil?
      
      nome = cliente.respond_to?(:nome) ? cliente.nome : 'cliente_indisponivel'
      nome.to_s.strip.empty? ? 'cliente_indisponivel' : nome.to_s.strip
    end

    def sanitize_name(name)
      return name if name.nil?
      
      sanitized = apply_character_normalization(name.to_s)
      sanitized = remove_invalid_characters(sanitized)
      sanitized = normalize_underscores(sanitized)
      sanitized = trim_underscores(sanitized)
      
      sanitized.empty? ? 'sem_nome' : sanitized
    end

    def apply_character_normalization(text)
      CHARACTER_MAPPING.reduce(text) { |result, (pattern, replacement)|
        result.gsub(pattern, replacement)
      }
    end

    def remove_invalid_characters(text)
      text.gsub(/[^\w\s_]/, '') # Remove special characters except spaces and underscores
    end

    def normalize_underscores(text)
      text.gsub(/\s+/, '_').gsub(/_+/, '_') # Replace spaces and multiple underscores
    end

    def trim_underscores(text)
      text.gsub(/^_|_$/, '').strip # Remove leading/trailing underscores
    end

    def format_date(date)
      return 'data_invalida' if date.nil?
      date.strftime('%Y%m%d')
    end
  end
end

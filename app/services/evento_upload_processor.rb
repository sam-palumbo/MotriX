require 'ostruct'

class EventoUploadProcessor
  class << self
    # Process multiple file uploads with document types and generate filenames
    # @param uploads [Array] - Array of {file:, document_type:} hashes
    # @param veiculo [Veiculo, nil] - Vehicle object
    # @param cliente [Cliente, nil] - Client object  
    # @param evento_date [Date] - Event date
    # @return [OpenStruct] - Result with processed_files and status
    def process_uploads(uploads:, veiculo:, cliente:, evento_date:)
      validate_uploads!(uploads)
      
      processed_files = []
      
      uploads.each do |upload|
        processed_file = process_single_upload(
          file: upload[:file],
          document_type: upload[:document_type],
          veiculo: veiculo,
          cliente: cliente,
          evento_date: evento_date
        )
        processed_files << processed_file
      end
      
      OpenStruct.new(
        success: true,
        processed_files: processed_files,
        total_files: processed_files.size
      )
    end

    private

    def validate_uploads!(uploads)
      raise 'Uploads cannot be empty' if uploads.nil? || uploads.empty?
      
      uploads.each do |upload|
        validate_document_type!(upload[:document_type])
        validate_file!(upload[:file])
      end
    end

    def validate_document_type!(document_type)
      raise 'Document type is required' if document_type.nil? || document_type.strip.empty?
    end

    def validate_file!(file)
      raise 'File is required' if file.nil?
      
      # Check file type
      allowed_types = %w[
        application/pdf
        image/jpeg
        image/png
        application/msword
        application/vnd.openxmlformats-officedocument.wordprocessingml.document
      ]
      
      raise 'File type not allowed' unless allowed_types.include?(file.content_type)
      
      # Check file size (5MB limit)
      max_size = 5.megabytes
      raise 'File size exceeds limit' if file.size > max_size
    end

    def process_single_upload(file:, document_type:, veiculo:, cliente:, evento_date:)
      # Generate filename using EventoFilenameGenerator
      filename = EventoFilenameGenerator.generate_filename(
        veiculo: veiculo,
        cliente: cliente,
        document_type: document_type,
        evento_date: evento_date
      )
      
      # Add file extension from original file
      filename_with_extension = "#{filename}#{File.extname(file.original_filename)}"
      
      {
        original_filename: file.original_filename,
        generated_filename: filename_with_extension,
        document_type: document_type,
        content_type: file.content_type,
        size: file.size,
        file: file
      }
    end
  end
end

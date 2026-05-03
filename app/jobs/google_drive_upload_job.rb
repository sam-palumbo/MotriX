class GoogleDriveUploadJob < ApplicationJob
  queue_as :default

  retry_on StandardError, wait: :exponentially_longer, attempts: 3

  def perform(file_path, folder_id, file_name, anexo_attributes, usuario_id)
    drive_service = GoogleDriveService.new

    File.open(file_path, "rb") do |file|
      result = drive_service.upload_file(
        file,
        folder_id: folder_id,
        file_name: file_name
      )

      # Create the Anexo record with the uploaded file URL
      Anexo.create!(
        anexo_attributes.merge(
          arquivo_url: result[:view_url],
          nome_arquivo: result[:file_name],
          mime_type: result[:mime_type],
          created_by_id: usuario_id,
          updated_by_id: usuario_id
        )
      )
    end
  ensure
    # Clean up temporary file
    File.delete(file_path) if File.exist?(file_path)
  end
end

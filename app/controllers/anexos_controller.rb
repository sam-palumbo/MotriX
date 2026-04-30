class AnexosController < ApplicationController
  before_action :set_parent_resource
  before_action :set_anexo, only: [ :destroy ]

  def create
    if anexo_params[:arquivo].blank?
      redirect_back fallback_location: parent_path, alert: "Selecione um arquivo para upload."
      return
    end

    arquivo = anexo_params[:arquivo]

    begin
      # Upload to Google Drive
      drive_service = GoogleDriveService.new
      upload_result = drive_service.upload_file(
        arquivo,
        folder_id: ENV["GOOGLE_DRIVE_VEICULOS_FOLDER_ID"],
        file_name: arquivo.original_filename
      )

      # Create anexo record
      anexo_attributes = {
        categoria: anexo_params[:categoria] || "documento",
        nome_arquivo: arquivo.original_filename,
        arquivo_url: upload_result[:view_url],
        mime_type: arquivo.content_type,
        created_by: Current.usuario,
        updated_by: Current.usuario
      }

      # Associate with veiculo if available
      if @veiculo
        anexo_attributes[:veiculo] = @veiculo
      elsif @evento&.veiculo
        anexo_attributes[:veiculo] = @evento.veiculo
      end

      # Associate with evento if available
      anexo_attributes[:evento] = @evento if @evento
      anexo_attributes[:evento_id] = anexo_params[:evento_id] if anexo_params[:evento_id].present?

      @anexo = Anexo.create!(anexo_attributes)

      redirect_back fallback_location: parent_path, notice: "Arquivo enviado com sucesso para o Google Drive."

    rescue StandardError => e
      Rails.logger.error "Erro no upload para Google Drive: #{e.message}"
      Rails.logger.error e.backtrace.join("\n")
      redirect_back fallback_location: parent_path, alert: "Erro ao enviar arquivo: #{e.message}"
    end
  end

  def destroy
    begin
      # Extract file ID from Google Drive URL
      file_id = extract_drive_file_id(@anexo.arquivo_url)

      if file_id
        drive_service = GoogleDriveService.new
        drive_service.delete_file(file_id)
      end

      @anexo.destroy
      redirect_back fallback_location: parent_path, notice: "Arquivo removido com sucesso."

    rescue StandardError => e
      Rails.logger.error "Erro ao remover arquivo do Google Drive: #{e.message}"
      # Still destroy the record even if Google Drive deletion fails
      @anexo.destroy
      redirect_back fallback_location: parent_path, notice: "Registro removido. (Erro ao remover do Google Drive: #{e.message})"
    end
  end

  private

  def set_parent_resource
    if params[:veiculo_id]
      @veiculo = Veiculo.find(params[:veiculo_id])
    elsif params[:evento_id]
      @evento = Evento.find(params[:evento_id])
    else
      redirect_to root_path, alert: "Recurso pai não encontrado."
    end
  end

  def set_anexo
    if @veiculo
      @anexo = @veiculo.anexos.find(params[:id])
    elsif @evento
      @anexo = @evento.anexos.find(params[:id])
    else
      redirect_to root_path, alert: "Anexo não encontrado."
    end
  end

  def parent_path
    if @veiculo
      veiculo_path(@veiculo)
    elsif @evento
      evento_path(@evento)
    else
      root_path
    end
  end

  def anexo_params
    params.require(:anexo).permit(:arquivo, :categoria, :evento_id)
  rescue ActionController::ParameterMissing
    # Handle case where anexo params might not be present
    params.permit(:arquivo, :categoria, :evento_id)
  end

  def extract_drive_file_id(url)
    return nil if url.blank?

    # Extract file ID from various Google Drive URL formats
    if url.match?(/\/d\/([^\/]+)/)
      url.match(/\/d\/([^\/]+)/)[1]
    elsif url.match?(/id=([^&]+)/)
      url.match(/id=([^&]+)/)[1]
    elsif url.match?(/\/file\/d\/([^\/]+)/)
      url.match(/\/file\/d\/([^\/]+)/)[1]
    else
      nil
    end
  end
end

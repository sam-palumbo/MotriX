class EventosController < ApplicationController
  before_action :set_evento, only: [ :show, :edit, :update, :destroy ]

  def index
    @eventos = Evento.includes(:cliente, :veiculo, :locacao).order(data_evento: :desc, created_at: :desc)
  end

  def show
  end

  def new
    @evento = Evento.new
    @clientes = Cliente.order(:nome)
    @veiculos = Veiculo.order(:placa)
    @locacoes = Locacao.order(:numero_contrato)

    # Pre-fill tipo_evento based on tipo parameter
    if params[:tipo].present?
      case params[:tipo]
      when 'pagamento_semanal'
        @evento.tipo_evento = 0
        @evento.fluxo = 0
        @evento.status = 1
        @evento.data_evento = Date.current
        @evento.periodo_inicio = Date.current.beginning_of_week
        @evento.periodo_fim = Date.current.end_of_week
      when 'retirada'
        @evento.tipo_evento = 3
        @evento.fluxo = 1
        @evento.status = 1
        @evento.data_evento = Date.current
      when 'devolucao'
        @evento.tipo_evento = 4
        @evento.fluxo = 1
        @evento.status = 1
        @evento.data_evento = Date.current
      when 'manutencao'
        @evento.tipo_evento = 1
        @evento.fluxo = 1
        @evento.status = 1
        @evento.data_evento = Date.current
      when 'gasto_empresa'
        @evento.tipo_evento = 2
        @evento.fluxo = 1
        @evento.status = 1
        @evento.data_evento = Date.current
      end
    end

    respond_to do |format|
      format.html
      format.turbo_stream
    end
  end

  def create
    @evento = Evento.new(evento_params)
    @evento.created_by = Current.usuario
    @evento.updated_by = Current.usuario

    respond_to do |format|
      if @evento.save
        # Handle file uploads to Google Drive
        upload_anexos_for_evento(@evento)

        format.html { redirect_to @evento, notice: "Evento criado com sucesso.#{upload_notice}" }
        format.turbo_stream
      else
        @clientes = Cliente.order(:nome)
        @veiculos = Veiculo.order(:placa)
        @locacoes = Locacao.order(:numero_contrato)
        format.html { render :new, status: :unprocessable_entity }
        format.turbo_stream
      end
    end
  end

  def edit
    @clientes = Cliente.order(:nome)
    @veiculos = Veiculo.order(:placa)
    @locacoes = Locacao.order(:numero_contrato)
    respond_to do |format|
      format.html
      format.turbo_stream
    end
  end

  def update
    @evento.updated_by = Current.usuario
    respond_to do |format|
      if @evento.update(evento_params)
        format.html { redirect_to @evento, notice: "Evento was successfully updated." }
        format.turbo_stream
      else
        @clientes = Cliente.order(:nome)
        @veiculos = Veiculo.order(:placa)
        @locacoes = Locacao.order(:numero_contrato)
        format.html { render :edit, status: :unprocessable_entity }
        format.turbo_stream
      end
    end
  end

  def destroy
    @evento.destroy
    redirect_to eventos_url, notice: "Evento was successfully deleted."
  end

  private

  def set_evento
    @evento = Evento.find(params[:id])
  end

  def evento_params
    permitted = params.require(:evento).permit(:cliente_id, :veiculo_id, :locacao_id, :tipo_evento, :tipo_manutencao, :fluxo, :status, :valor, :periodo_inicio, :periodo_fim, :quilometragem, :responsavel, :descricao, :data_evento)
    permitted[:status] = permitted[:status].to_i if permitted[:status].present?
    permitted[:tipo_evento] = permitted[:tipo_evento].to_i if permitted[:tipo_evento].present?
    permitted[:tipo_manutencao] = permitted[:tipo_manutencao].to_i if permitted[:tipo_manutencao].present?
    permitted[:fluxo] = permitted[:fluxo].to_i if permitted[:fluxo].present?
    permitted
  end

  def upload_anexos_for_evento(evento)
    Rails.logger.info "upload_anexos_for_evento called for evento #{evento.id}"
    Rails.logger.info "params[:anexos]: #{params[:anexos].inspect}"
    return unless params[:anexos].present?

    uploaded_count = 0
    drive_service = GoogleDriveService.new
    folder_id = ENV["GOOGLE_DRIVE_VEICULOS_FOLDER_ID"] || ENV["GOOGLE_DRIVE_DEFAULT_FOLDER_ID"]

    params[:anexos].each do |key, anexo_params|
      arquivo = anexo_params[:arquivo]
      Rails.logger.info "Processing anexo #{key}, arquivo: #{arquivo.inspect}"
      next if arquivo.blank?

      categoria = anexo_params[:categoria] || key.to_s

      begin
        # Upload to Google Drive
        upload_result = drive_service.upload_file(
          arquivo,
          folder_id: folder_id,
          file_name: arquivo.original_filename
        )

        # Create anexo record associated with evento and veiculo
        Anexo.create!(
          veiculo: evento.veiculo,
          evento: evento,
          categoria: categoria,
          nome_arquivo: arquivo.original_filename,
          arquivo_url: upload_result[:view_url],
          mime_type: arquivo.content_type,
          created_by: Current.usuario,
          updated_by: Current.usuario
        )

        uploaded_count += 1
        Rails.logger.info "Successfully uploaded #{arquivo.original_filename}"

      rescue StandardError => e
        Rails.logger.error "Erro ao fazer upload de anexo para evento #{evento.id}: #{e.message}"
        Rails.logger.error e.backtrace.join("\n")
        # Continue with other files even if one fails
      end
    end

    @uploaded_anexos_count = uploaded_count
  end

  def upload_notice
    return "" if @uploaded_anexos_count.nil? || @uploaded_anexos_count == 0
    " #{@uploaded_anexos_count} arquivo(s) anexado(s) ao Google Drive."
  end
end

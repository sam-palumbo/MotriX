class VeiculosController < ApplicationController
  before_action :set_veiculo, only: [ :show, :edit, :update, :destroy, :retirar_frota, :manutencao ]

  def index
    @veiculos = Veiculo.order(:placa)
  end

  def show
    respond_to do |format|
      format.html
      format.turbo_stream
    end
  end

  def new
    @veiculo = Veiculo.new
    respond_to do |format|
      format.html
      format.turbo_stream
    end
  end

  def create
    @veiculo = Veiculo.new(veiculo_params)
    @veiculo.created_by = Current.usuario
    @veiculo.updated_by = Current.usuario

    respond_to do |format|
      if @veiculo.save
        format.html { redirect_to @veiculo, notice: "Veiculo was successfully created." }
        format.turbo_stream
      else
        format.html { render :new, status: :unprocessable_entity }
        format.turbo_stream
      end
    end
  end

  def edit
    respond_to do |format|
      format.html
      format.turbo_stream
    end
  end

  def update
    @veiculo.updated_by = Current.usuario
    respond_to do |format|
      if @veiculo.update(veiculo_params)
        format.html { redirect_to @veiculo, notice: "Veiculo was successfully updated." }
        format.turbo_stream
      else
        format.html { render :edit, status: :unprocessable_entity }
        format.turbo_stream
      end
    end
  end

  def destroy
    @veiculo.destroy
    redirect_to veiculos_url, notice: "Veiculo was successfully deleted."
  end

  def retirar_frota_form
    render :retirar_frota
  end

  def retirar_frota
    motivo = params[:motivo] || "outros"
    data_evento = params[:data_evento] || Date.current.to_s
    valor = params[:valor] || "0"
    observacoes = params[:observacoes] || "Retirada da frota"

    ActiveRecord::Base.transaction do
      # Mark vehicle as inactive
      @veiculo.update!(status: :inativo, updated_by: Current.usuario)

      # Create financial event for removal
      evento = Evento.new(
        tipo_evento: :saida_frota,
        fluxo: :entrada,
        valor: valor.to_f,
        responsavel: Current.usuario.nome,
        data_evento: data_evento,
        descricao: "Retirada da frota - #{motivo}: #{observacoes}",
        status: :pago,
        veiculo: @veiculo,
        created_by: Current.usuario,
        updated_by: Current.usuario
      )

      if evento.valid?
        evento.save!
      else
        raise ActiveRecord::RecordInvalid.new(evento)
      end
    end

    redirect_to veiculos_path, notice: "Veículo retirado da frota com sucesso!"
  rescue ActiveRecord::RecordInvalid => e
    error_message = e.record.errors.full_messages.join(", ")
    redirect_to veiculo_path(@veiculo), alert: "Erro ao retirar veículo: #{error_message}"
  rescue => e
    redirect_to veiculos_path, alert: "Erro ao retirar veículo: #{e.message}"
  end

  def new_manutencao
    @veiculo_id = params[:veiculo_id]
    render :new_manutencao
  end

  def manutencao
    tipo_manutencao = params[:tipo_manutencao] || "outros"
    valor = params[:valor] || "0"
    quilometragem = params[:quilometragem]
    data_evento = params[:data_evento] || Date.current.to_s
    responsavel = params[:responsavel] || Current.usuario&.nome || "Sistema"
    descricao = params[:descricao] || "Manutenção registrada"
    veiculo_id = params[:veiculo_id]

    # Debug logging
    Rails.logger.debug "Manutenção params: #{params.inspect}"
    Rails.logger.debug "tipo_manutencao: #{tipo_manutencao.inspect}"
    Rails.logger.debug "valor: #{valor.inspect}"
    Rails.logger.debug "data_evento: #{data_evento.inspect}"
    Rails.logger.debug "responsavel: #{responsavel.inspect}"

    ActiveRecord::Base.transaction do
      # Update vehicle mileage if provided
      if quilometragem.present?
        veiculo = Veiculo.find(veiculo_id)
        veiculo.update!(km_atual: quilometragem, updated_by: Current.usuario)
      end

      # Create financial event for the maintenance
      evento = Evento.new(
        tipo_evento: :manutencao,
        tipo_manutencao: tipo_manutencao,
        fluxo: :saida,
        valor: valor.to_f,
        responsavel: responsavel,
        data_evento: data_evento,
        descricao: "Manutenção - #{tipo_manutencao}: #{descricao}",
        status: :pago,
        veiculo: Veiculo.find(veiculo_id),
        created_by: Current.usuario,
        updated_by: Current.usuario
      )

      if evento.valid?
        evento.save!
      else
        raise ActiveRecord::RecordInvalid.new(evento)
      end
    end

    redirect_to veiculo_path(veiculo_id), notice: "Manutenção registrada com sucesso!"
  rescue ActiveRecord::RecordInvalid => e
    error_message = e.record.errors.full_messages.join(", ")
    redirect_to new_manutencao_veiculos_path(veiculo_id: veiculo_id), alert: "Erro ao registrar manutenção: #{error_message}"
  rescue => e
    redirect_to veiculos_path, alert: "Erro ao registrar manutenção: #{e.message}"
  end

  private

  def set_veiculo
    @veiculo = Veiculo.find(params[:id])
  end

  def veiculo_params
    permitted = params.require(:veiculo).permit(:placa, :renavam, :chassi, :marca, :modelo, :ano, :cor, :data_compra, :valor_compra, :valor_aquisicao, :valor_semanal, :valor_diaria, :km_aquisicao, :km_atual, :status, :primeira_locacao_em, :caucao_retida)
    permitted[:status] = permitted[:status].to_i if permitted[:status].present?
    permitted
  end
end

module Veiculos
  class MaintenanceTracker < ApplicationService
    MAINTENANCE_INTERVALS = {
      "Troca de óleo" => 3000,
      "Troca da relação" => 15000,
      "Pastilhas de freio dianteira" => 12000,
      "Disco de freio dianteiro" => 24000,
      "Lona de freio traseira" => 18000,
      "Pneu dianteiro" => 15000,
      "Pneu traseiro" => 12000,
      "Vela de ignição" => 6000
    }.freeze

    DRUM_BRAKE_PLATES = [ "SDL2H36", "ROM2A60", "SMD4E03" ].freeze

    def initialize(veiculo:)
      @veiculo = veiculo
    end

    def call
      {
        items: maintenance_items,
        history: maintenance_history,
        alerts: maintenance_alerts
      }
    end

    def maintenance_items
      intervals = adjusted_intervals
      current_km = @veiculo.km_atual || 0
      items = []

      intervals.each do |type, interval|
        last_maintenance = find_last_maintenance(type)
        last_km = last_maintenance&.quilometragem || @veiculo.km_aquisicao || 0
        next_km = last_km + interval
        km_remaining = next_km - current_km

        progress = calculate_progress(current_km, last_km, interval)
        status = determine_status(progress, current_km, next_km, km_remaining)

        items << build_item(type, last_km, next_km, current_km, progress, status, interval)
      end

      items.sort_by { |item| item[:progress_percentage] }.reverse
    end

    def maintenance_alerts
      items = maintenance_items
      overdue = items.count { |item| item[:progress_percentage] >= 100 }
      upcoming = items.count { |item| item[:progress_percentage] >= 70 && item[:progress_percentage] < 100 }

      {
        overdue: overdue,
        upcoming: upcoming
      }
    end

    def maintenance_history
      Evento.where(
        veiculo: @veiculo,
        tipo_evento: :manutencao
      ).order(data_evento: :desc).limit(10).map do |event|
        {
          type: event.tipo_manutencao&.humanize || "Manutenção",
          date: event.data_evento.strftime("%d/%m/%Y"),
          km: event.quilometragem || 0,
          cost: event.valor || 0,
          description: event.descricao
        }
      end
    end

    private

    def adjusted_intervals
      intervals = MAINTENANCE_INTERVALS.dup

      if has_drum_brake?
        intervals["Lona de freio dianteira"] = 15000
        intervals.delete("Pastilhas de freio dianteira")
        intervals.delete("Disco de freio dianteiro")
      end

      intervals
    end

    def has_drum_brake?
      DRUM_BRAKE_PLATES.include?(@veiculo.placa)
    end

    def find_last_maintenance(type)
      Evento.where(
        veiculo: @veiculo,
        tipo_evento: :manutencao,
        tipo_manutencao: type.parameterize(separator: "_")
      ).order(data_evento: :desc).first
    end

    def calculate_progress(current_km, last_km, interval)
      progress = ((current_km - last_km).to_f / interval * 100).round(1)
      [[progress, 100].min, 0].max
    end

    def determine_status(progress, current_km, next_km, km_remaining)
      if current_km >= next_km
        {
          icon: "!",
          text: "VENCIDO",
          color: "var(--red)"
        }
      elsif progress >= 70
        {
          icon: "!",
          text: "+#{km_remaining.to_fs(:delimited)}",
          color: "var(--orange)"
        }
      else
        {
          icon: "!",
          text: "+#{km_remaining.to_fs(:delimited)}",
          color: "var(--green)"
        }
      end
    end

    def build_item(type, last_km, next_km, current_km, progress, status, interval)
      {
        type: type,
        last_km: last_km,
        next_km: next_km,
        current_km: current_km,
        progress_percentage: progress,
        progress_color: status[:color],
        status_icon: status[:icon],
        status_text: status[:text],
        interval: interval
      }
    end
  end
end

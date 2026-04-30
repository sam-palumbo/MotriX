module ApplicationHelper
  # Simple icon helper using emoji or SVG icons
  def ui_icon(name, size: 16, style: "", class_name: "")
    icon_emoji = {
      "cloud-upload" => "☁️",
      "paperclip" => "📎",
      "external-link" => "🔗",
      "trash" => "🗑️"
    }[name.to_s] || "•"
    
    content_tag(:span, icon_emoji, style: "font-size: #{size}px; #{style}; vertical-align: middle; #{class_name}")
  end

  def brl(value)
    number_to_currency(value || 0, unit: "R$ ", separator: ",", delimiter: ".", precision: 2)
  end

  def enum_label(value)
    value.to_s.humanize
  end

  def nav_link_to(label, path)
    classes = if current_page?(path)
      "rounded-full bg-stone-900 px-3 py-2 text-sm font-medium text-white"
    else
      "rounded-full px-3 py-2 text-sm font-medium text-stone-600 transition hover:bg-stone-200 hover:text-stone-900"
    end

    link_to label, path, class: classes
  end

  def flash_classes(kind)
    case kind.to_sym
    when :notice
      "border-emerald-200 bg-emerald-50 text-emerald-700"
    when :alert
      "border-rose-200 bg-rose-50 text-rose-700"
    else
      "border-stone-200 bg-white text-stone-700"
    end
  end

  def badge_classes(value)
    case value.to_s
    when "admin", "ativo", "disponivel", "ativa", "pago", "entrada"
      "bg-emerald-100 text-emerald-700"
    when "operador", "manutencao", "parcial", "locado", "pendente"
      "bg-amber-100 text-amber-700"
    when "bloqueado", "inativo", "cancelada", "inadimplente", "saida"
      "bg-rose-100 text-rose-700"
    else
      "bg-stone-200 text-stone-700"
    end
  end

  def flash_alert_class(kind)
    case kind.to_sym
    when :notice
      "green"
    when :alert
      "red"
    when :warning
      "orange"
    when :info
      "blue"
    else
      "yellow"
    end
  end

  def flash_icon(kind)
    case kind.to_sym
    when :notice
      "✓"
    when :alert
      "⚠"
    when :warning
      "⚡"
    when :info
      "ℹ"
    else
      "📢"
    end
  end

  def flash_title(kind)
    case kind.to_sym
    when :notice
      "Sucesso"
    when :alert
      "Erro"
    when :warning
      "Aviso"
    when :info
      "Informação"
    else
      "Notificação"
    end
  end
end

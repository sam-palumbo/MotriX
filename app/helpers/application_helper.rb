module ApplicationHelper
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
end

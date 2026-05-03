require "nokogiri"

module FormHelpers
  def form_control_names
    Nokogiri::HTML(response.body).css("input[name], select[name], textarea[name]").filter_map do |field|
      name = field["name"]
      next if name == "authenticity_token"
      next if name == "_method"
      name
    end.uniq
  end

  def expect_form_fields_for(param_key, fields)
    expected_names = fields.map { |field| "#{param_key}[#{field}]" }

    expect(form_control_names).to include(*expected_names)
  end

  def expect_form_fields_only_for(param_key, fields, extra_names: [])
    expected_names = fields.map { |field| "#{param_key}[#{field}]" } + extra_names
    actual_names = form_control_names.select { |name| name.start_with?("#{param_key}[") || extra_names.include?(name) }

    expect(actual_names).to match_array(expected_names)
  end
end

RSpec.configure do |config|
  config.include FormHelpers, type: :request
end

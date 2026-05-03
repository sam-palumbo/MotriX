module EnumParamsConverter
  extend ActiveSupport::Concern

  private

  def convert_enum_params(permitted, *fields)
    fields.each do |field|
      permitted[field] = permitted[field].to_i if permitted[field].present?
    end
    permitted
  end
end

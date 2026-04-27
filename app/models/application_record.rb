class ApplicationRecord < ActiveRecord::Base
  primary_abstract_class

  def self.tracked_by_users(optional: false)
    belongs_to :created_by, class_name: "Usuario", optional: optional
    belongs_to :updated_by, class_name: "Usuario", optional: optional
  end
end

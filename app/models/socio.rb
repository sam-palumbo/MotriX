class Socio < ApplicationRecord
  tracked_by_users

  has_many :participacao_socios, dependent: :destroy
  has_many :veiculos, through: :participacao_socios

  validates :cpf, :nome, presence: true
  validates :cpf, uniqueness: true

  def to_s
    nome
  end
end

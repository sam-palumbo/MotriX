module LoadAssociations
  extend ActiveSupport::Concern

  private

  def load_clientes
    @clientes = Cliente.order(:nome)
  end

  def load_veiculos
    @veiculos = Veiculo.order(:placa)
  end

  def load_locacoes
    @locacoes = Locacao.order(:numero_contrato)
  end
end

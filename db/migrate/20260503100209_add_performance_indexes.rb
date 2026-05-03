class AddPerformanceIndexes < ActiveRecord::Migration[8.1]
  def change
    # Composite index for eventos to optimize queries by vehicle, flow, and date
    unless index_exists?(:eventos, [ :veiculo_id, :fluxo, :data_evento ])
      add_index :eventos, [ :veiculo_id, :fluxo, :data_evento ]
    end

    # Composite index for eventos to optimize queries by locacao and date
    # This index already exists, so we skip it
    # unless index_exists?(:eventos, [:locacao_id, :data_evento])
    #   add_index :eventos, [:locacao_id, :data_evento]
    # end

    # Index for locacoes status filtering
    unless index_exists?(:locacoes, :status)
      add_index :locacoes, :status
    end

    # Index for veiculos status filtering
    unless index_exists?(:veiculos, :status)
      add_index :veiculos, :status
    end
  end
end

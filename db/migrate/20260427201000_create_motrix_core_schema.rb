class CreateMotrixCoreSchema < ActiveRecord::Migration[8.0]
  def change
    enable_extension "pgcrypto" unless extension_enabled?("pgcrypto")

    create_table :usuarios, id: :uuid do |t|
      t.string :cpf, null: false
      t.string :nome, null: false
      t.string :email, null: false
      t.string :senha_hash, null: false
      t.integer :perfil, null: false, default: 1
      t.boolean :ativo, null: false, default: true
      t.references :created_by, type: :uuid, foreign_key: { to_table: :usuarios }, null: true
      t.references :updated_by, type: :uuid, foreign_key: { to_table: :usuarios }, null: true
      t.timestamps
    end
    add_index :usuarios, :cpf, unique: true
    add_index :usuarios, :email, unique: true

    create_table :clientes, id: :uuid do |t|
      t.string :cpf, null: false
      t.string :nome, null: false
      t.string :telefone
      t.string :email
      t.string :endereco
      t.string :cidade
      t.string :estado
      t.string :cep
      t.string :cnh
      t.date :validade_cnh
      t.integer :status, null: false, default: 0
      t.text :observacoes
      t.references :created_by, type: :uuid, foreign_key: { to_table: :usuarios }, null: false
      t.references :updated_by, type: :uuid, foreign_key: { to_table: :usuarios }, null: false
      t.timestamps
    end
    add_index :clientes, :cpf, unique: true

    create_table :veiculos, id: :uuid do |t|
      t.string :placa, null: false
      t.string :renavam, null: false
      t.string :chassi, null: false
      t.string :marca
      t.string :modelo
      t.integer :ano
      t.string :cor
      t.date :data_compra
      t.decimal :valor_compra, precision: 12, scale: 2
      t.decimal :valor_aquisicao, precision: 12, scale: 2
      t.decimal :valor_semanal, precision: 12, scale: 2
      t.decimal :valor_diaria, precision: 12, scale: 2
      t.integer :km_aquisicao
      t.integer :km_atual
      t.integer :status, null: false, default: 0
      t.date :primeira_locacao_em
      t.decimal :caucao_retida, precision: 12, scale: 2
      t.references :created_by, type: :uuid, foreign_key: { to_table: :usuarios }, null: false
      t.references :updated_by, type: :uuid, foreign_key: { to_table: :usuarios }, null: false
      t.timestamps
    end
    add_index :veiculos, :placa, unique: true
    add_index :veiculos, :renavam, unique: true
    add_index :veiculos, :chassi, unique: true

    create_table :locacoes, id: :uuid do |t|
      t.string :numero_contrato, null: false
      t.references :cliente, type: :uuid, foreign_key: true, null: false
      t.references :veiculo, type: :uuid, foreign_key: true, null: false
      t.date :data_inicio, null: false
      t.date :data_prevista_fim, null: false
      t.date :data_fim
      t.decimal :valor_semanal, precision: 12, scale: 2, null: false
      t.decimal :caucao_valor, precision: 12, scale: 2
      t.boolean :caucao_recebida, null: false, default: false
      t.boolean :caucao_devolvida, null: false, default: false
      t.integer :status, null: false, default: 0
      t.text :observacoes
      t.references :created_by, type: :uuid, foreign_key: { to_table: :usuarios }, null: false
      t.references :updated_by, type: :uuid, foreign_key: { to_table: :usuarios }, null: false
      t.timestamps
    end
    add_index :locacoes, :numero_contrato, unique: true
    add_index :locacoes, :status

    create_table :eventos, id: :uuid do |t|
      t.references :cliente, type: :uuid, foreign_key: true, null: true
      t.references :veiculo, type: :uuid, foreign_key: true, null: true
      t.references :locacao, type: :uuid, foreign_key: { to_table: :locacoes }, null: true
      t.integer :tipo_evento, null: false
      t.integer :tipo_manutencao
      t.integer :fluxo, null: false
      t.integer :status
      t.decimal :valor, precision: 12, scale: 2, null: false
      t.date :periodo_inicio
      t.date :periodo_fim
      t.integer :quilometragem
      t.string :responsavel, null: false
      t.text :descricao
      t.date :data_evento, null: false
      t.references :created_by, type: :uuid, foreign_key: { to_table: :usuarios }, null: false
      t.references :updated_by, type: :uuid, foreign_key: { to_table: :usuarios }, null: false
      t.timestamps
    end
    add_index :eventos, :data_evento
    add_index :eventos, :tipo_evento
    add_index :eventos, %i[veiculo_id data_evento]
    add_index :eventos, %i[locacao_id data_evento]

    create_table :socios, id: :uuid do |t|
      t.string :cpf, null: false
      t.string :nome, null: false
      t.string :telefone
      t.string :email
      t.references :created_by, type: :uuid, foreign_key: { to_table: :usuarios }, null: false
      t.references :updated_by, type: :uuid, foreign_key: { to_table: :usuarios }, null: false
      t.timestamps
    end
    add_index :socios, :cpf, unique: true

    create_table :participacao_socios, id: :uuid do |t|
      t.references :socio, type: :uuid, foreign_key: true, null: false
      t.references :veiculo, type: :uuid, foreign_key: true, null: false
      t.decimal :percentual_participacao, precision: 5, scale: 2, null: false
      t.decimal :valor_investido, precision: 12, scale: 2
      t.references :created_by, type: :uuid, foreign_key: { to_table: :usuarios }, null: false
      t.references :updated_by, type: :uuid, foreign_key: { to_table: :usuarios }, null: false
      t.timestamps
    end
    add_index :participacao_socios, %i[socio_id veiculo_id], unique: true

    create_table :anexos, id: :uuid do |t|
      t.references :veiculo, type: :uuid, foreign_key: true, null: false
      t.references :evento, type: :uuid, foreign_key: true, null: true
      t.string :categoria, null: false
      t.string :nome_arquivo, null: false
      t.string :arquivo_url, null: false
      t.string :mime_type, null: false
      t.references :created_by, type: :uuid, foreign_key: { to_table: :usuarios }, null: false
      t.references :updated_by, type: :uuid, foreign_key: { to_table: :usuarios }, null: false
      t.timestamps
    end

    create_table :auditoria_logs, id: :uuid do |t|
      t.references :usuario, type: :uuid, foreign_key: true, null: false
      t.string :acao, null: false
      t.string :tipo_evento, null: false
      t.references :veiculo, type: :uuid, foreign_key: true, null: true
      t.decimal :valor, precision: 12, scale: 2
      t.text :detalhes
      t.datetime :created_at, null: false
    end
  end
end

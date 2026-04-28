# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# This file is the source Rails uses to define your schema when running `bin/rails
# db:schema:load`. When creating a new database, `bin/rails db:schema:load` tends to
# be faster and is potentially less error prone than running all of your
# migrations from scratch. Old migrations may fail to apply correctly if those
# migrations use external dependencies or application code.
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema[8.0].define(version: 2026_04_27_201000) do
  create_schema "auth"
  create_schema "extensions"
  create_schema "graphql"
  create_schema "graphql_public"
  create_schema "pgbouncer"
  create_schema "realtime"
  create_schema "storage"
  create_schema "vault"

  # These are extensions that must be enabled in order to support this database
  enable_extension "extensions.pg_stat_statements"
  enable_extension "extensions.pgcrypto"
  enable_extension "extensions.uuid-ossp"
  enable_extension "pg_catalog.plpgsql"
  enable_extension "vault.supabase_vault"

  create_table "anexos", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.uuid "veiculo_id", null: false
    t.uuid "evento_id"
    t.string "categoria", null: false
    t.string "nome_arquivo", null: false
    t.string "arquivo_url", null: false
    t.string "mime_type", null: false
    t.uuid "created_by_id", null: false
    t.uuid "updated_by_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["created_by_id"], name: "index_anexos_on_created_by_id"
    t.index ["evento_id"], name: "index_anexos_on_evento_id"
    t.index ["updated_by_id"], name: "index_anexos_on_updated_by_id"
    t.index ["veiculo_id"], name: "index_anexos_on_veiculo_id"
  end

  create_table "auditoria_logs", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.uuid "usuario_id", null: false
    t.string "acao", null: false
    t.string "tipo_evento", null: false
    t.uuid "veiculo_id"
    t.decimal "valor", precision: 12, scale: 2
    t.text "detalhes"
    t.datetime "created_at", null: false
    t.index ["usuario_id"], name: "index_auditoria_logs_on_usuario_id"
    t.index ["veiculo_id"], name: "index_auditoria_logs_on_veiculo_id"
  end

  create_table "clientes", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.string "cpf", null: false
    t.string "nome", null: false
    t.string "telefone"
    t.string "email"
    t.string "endereco"
    t.string "cidade"
    t.string "estado"
    t.string "cep"
    t.string "cnh"
    t.date "validade_cnh"
    t.integer "status", default: 0, null: false
    t.text "observacoes"
    t.uuid "created_by_id", null: false
    t.uuid "updated_by_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["cpf"], name: "index_clientes_on_cpf", unique: true
    t.index ["created_by_id"], name: "index_clientes_on_created_by_id"
    t.index ["updated_by_id"], name: "index_clientes_on_updated_by_id"
  end

  create_table "eventos", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.uuid "cliente_id"
    t.uuid "veiculo_id"
    t.uuid "locacao_id"
    t.integer "tipo_evento", null: false
    t.integer "tipo_manutencao"
    t.integer "fluxo", null: false
    t.integer "status"
    t.decimal "valor", precision: 12, scale: 2, null: false
    t.date "periodo_inicio"
    t.date "periodo_fim"
    t.integer "quilometragem"
    t.string "responsavel", null: false
    t.text "descricao"
    t.date "data_evento", null: false
    t.uuid "created_by_id", null: false
    t.uuid "updated_by_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["cliente_id"], name: "index_eventos_on_cliente_id"
    t.index ["created_by_id"], name: "index_eventos_on_created_by_id"
    t.index ["data_evento"], name: "index_eventos_on_data_evento"
    t.index ["locacao_id", "data_evento"], name: "index_eventos_on_locacao_id_and_data_evento"
    t.index ["locacao_id"], name: "index_eventos_on_locacao_id"
    t.index ["tipo_evento"], name: "index_eventos_on_tipo_evento"
    t.index ["updated_by_id"], name: "index_eventos_on_updated_by_id"
    t.index ["veiculo_id", "data_evento"], name: "index_eventos_on_veiculo_id_and_data_evento"
    t.index ["veiculo_id"], name: "index_eventos_on_veiculo_id"
  end

  create_table "locacoes", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.string "numero_contrato", null: false
    t.uuid "cliente_id", null: false
    t.uuid "veiculo_id", null: false
    t.date "data_inicio", null: false
    t.date "data_prevista_fim", null: false
    t.date "data_fim"
    t.decimal "valor_semanal", precision: 12, scale: 2, null: false
    t.decimal "caucao_valor", precision: 12, scale: 2
    t.boolean "caucao_recebida", default: false, null: false
    t.boolean "caucao_devolvida", default: false, null: false
    t.integer "status", default: 0, null: false
    t.text "observacoes"
    t.uuid "created_by_id", null: false
    t.uuid "updated_by_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["cliente_id"], name: "index_locacoes_on_cliente_id"
    t.index ["created_by_id"], name: "index_locacoes_on_created_by_id"
    t.index ["numero_contrato"], name: "index_locacoes_on_numero_contrato", unique: true
    t.index ["status"], name: "index_locacoes_on_status"
    t.index ["updated_by_id"], name: "index_locacoes_on_updated_by_id"
    t.index ["veiculo_id"], name: "index_locacoes_on_veiculo_id"
  end

  create_table "participacao_socios", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.uuid "socio_id", null: false
    t.uuid "veiculo_id", null: false
    t.decimal "percentual_participacao", precision: 5, scale: 2, null: false
    t.decimal "valor_investido", precision: 12, scale: 2
    t.uuid "created_by_id", null: false
    t.uuid "updated_by_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["created_by_id"], name: "index_participacao_socios_on_created_by_id"
    t.index ["socio_id", "veiculo_id"], name: "index_participacao_socios_on_socio_id_and_veiculo_id", unique: true
    t.index ["socio_id"], name: "index_participacao_socios_on_socio_id"
    t.index ["updated_by_id"], name: "index_participacao_socios_on_updated_by_id"
    t.index ["veiculo_id"], name: "index_participacao_socios_on_veiculo_id"
  end

  create_table "socios", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.string "cpf", null: false
    t.string "nome", null: false
    t.string "telefone"
    t.string "email"
    t.uuid "created_by_id", null: false
    t.uuid "updated_by_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["cpf"], name: "index_socios_on_cpf", unique: true
    t.index ["created_by_id"], name: "index_socios_on_created_by_id"
    t.index ["updated_by_id"], name: "index_socios_on_updated_by_id"
  end

  create_table "usuarios", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.string "cpf", null: false
    t.string "nome", null: false
    t.string "email", null: false
    t.string "senha_hash", null: false
    t.integer "perfil", default: 1, null: false
    t.boolean "ativo", default: true, null: false
    t.uuid "created_by_id"
    t.uuid "updated_by_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["cpf"], name: "index_usuarios_on_cpf", unique: true
    t.index ["created_by_id"], name: "index_usuarios_on_created_by_id"
    t.index ["email"], name: "index_usuarios_on_email", unique: true
    t.index ["updated_by_id"], name: "index_usuarios_on_updated_by_id"
  end

  create_table "veiculos", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.string "placa", null: false
    t.string "renavam", null: false
    t.string "chassi", null: false
    t.string "marca"
    t.string "modelo"
    t.integer "ano"
    t.string "cor"
    t.date "data_compra"
    t.decimal "valor_compra", precision: 12, scale: 2
    t.decimal "valor_aquisicao", precision: 12, scale: 2
    t.decimal "valor_semanal", precision: 12, scale: 2
    t.decimal "valor_diaria", precision: 12, scale: 2
    t.integer "km_aquisicao"
    t.integer "km_atual"
    t.integer "status", default: 0, null: false
    t.date "primeira_locacao_em"
    t.decimal "caucao_retida", precision: 12, scale: 2
    t.uuid "created_by_id", null: false
    t.uuid "updated_by_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["chassi"], name: "index_veiculos_on_chassi", unique: true
    t.index ["created_by_id"], name: "index_veiculos_on_created_by_id"
    t.index ["placa"], name: "index_veiculos_on_placa", unique: true
    t.index ["renavam"], name: "index_veiculos_on_renavam", unique: true
    t.index ["updated_by_id"], name: "index_veiculos_on_updated_by_id"
  end

  add_foreign_key "anexos", "eventos"
  add_foreign_key "anexos", "usuarios", column: "created_by_id"
  add_foreign_key "anexos", "usuarios", column: "updated_by_id"
  add_foreign_key "anexos", "veiculos"
  add_foreign_key "auditoria_logs", "usuarios"
  add_foreign_key "auditoria_logs", "veiculos"
  add_foreign_key "clientes", "usuarios", column: "created_by_id"
  add_foreign_key "clientes", "usuarios", column: "updated_by_id"
  add_foreign_key "eventos", "clientes"
  add_foreign_key "eventos", "locacoes"
  add_foreign_key "eventos", "usuarios", column: "created_by_id"
  add_foreign_key "eventos", "usuarios", column: "updated_by_id"
  add_foreign_key "eventos", "veiculos"
  add_foreign_key "locacoes", "clientes"
  add_foreign_key "locacoes", "usuarios", column: "created_by_id"
  add_foreign_key "locacoes", "usuarios", column: "updated_by_id"
  add_foreign_key "locacoes", "veiculos"
  add_foreign_key "participacao_socios", "socios"
  add_foreign_key "participacao_socios", "usuarios", column: "created_by_id"
  add_foreign_key "participacao_socios", "usuarios", column: "updated_by_id"
  add_foreign_key "participacao_socios", "veiculos"
  add_foreign_key "socios", "usuarios", column: "created_by_id"
  add_foreign_key "socios", "usuarios", column: "updated_by_id"
  add_foreign_key "usuarios", "usuarios", column: "created_by_id"
  add_foreign_key "usuarios", "usuarios", column: "updated_by_id"
  add_foreign_key "veiculos", "usuarios", column: "created_by_id"
  add_foreign_key "veiculos", "usuarios", column: "updated_by_id"
end

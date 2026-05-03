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

ActiveRecord::Schema[8.1].define(version: 2026_05_03_160000) do
  create_schema "extensions"

  # These are extensions that must be enabled in order to support this database
  enable_extension "extensions.pg_stat_statements"
  enable_extension "extensions.pgcrypto"
  enable_extension "extensions.uuid-ossp"
  enable_extension "pg_catalog.plpgsql"
  enable_extension "vault.supabase_vault"

  create_table "public.anexos", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.string "arquivo_url", null: false
    t.string "categoria", null: false
    t.datetime "created_at", null: false
    t.uuid "created_by_id", null: false
    t.uuid "evento_id"
    t.string "mime_type", null: false
    t.string "nome_arquivo", null: false
    t.datetime "updated_at", null: false
    t.uuid "updated_by_id", null: false
    t.uuid "veiculo_id", null: false
    t.index ["created_by_id"], name: "index_anexos_on_created_by_id"
    t.index ["evento_id"], name: "index_anexos_on_evento_id"
    t.index ["updated_by_id"], name: "index_anexos_on_updated_by_id"
    t.index ["veiculo_id"], name: "index_anexos_on_veiculo_id"
  end

  create_table "public.auditoria_logs", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.string "acao", null: false
    t.datetime "created_at", null: false
    t.text "detalhes"
    t.string "tipo_evento", null: false
    t.uuid "usuario_id", null: false
    t.decimal "valor", precision: 12, scale: 2
    t.uuid "veiculo_id"
    t.index ["usuario_id"], name: "index_auditoria_logs_on_usuario_id"
    t.index ["veiculo_id"], name: "index_auditoria_logs_on_veiculo_id"
  end

  create_table "public.clientes", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.string "cep"
    t.string "cidade"
    t.string "cnh"
    t.string "cpf", null: false
    t.datetime "created_at", null: false
    t.uuid "created_by_id", null: false
    t.string "email"
    t.string "endereco"
    t.string "estado"
    t.string "nome", null: false
    t.text "observacoes"
    t.integer "status", default: 0, null: false
    t.string "telefone"
    t.datetime "updated_at", null: false
    t.uuid "updated_by_id", null: false
    t.date "validade_cnh"
    t.index ["cpf"], name: "index_clientes_on_cpf", unique: true
    t.index ["created_by_id"], name: "index_clientes_on_created_by_id"
    t.index ["updated_by_id"], name: "index_clientes_on_updated_by_id"
  end

  create_table "public.eventos", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.uuid "cliente_id"
    t.datetime "created_at", null: false
    t.uuid "created_by_id", null: false
    t.date "data_evento", null: false
    t.text "descricao"
    t.integer "fluxo", null: false
    t.uuid "locacao_id"
    t.date "periodo_fim"
    t.date "periodo_inicio"
    t.integer "quilometragem"
    t.string "responsavel", null: false
    t.integer "status"
    t.integer "tipo_evento", null: false
    t.integer "tipo_manutencao"
    t.datetime "updated_at", null: false
    t.uuid "updated_by_id", null: false
    t.decimal "valor", precision: 12, scale: 2, null: false
    t.uuid "veiculo_id"
    t.index ["cliente_id"], name: "index_eventos_on_cliente_id"
    t.index ["created_by_id"], name: "index_eventos_on_created_by_id"
    t.index ["data_evento"], name: "index_eventos_on_data_evento"
    t.index ["locacao_id", "data_evento"], name: "index_eventos_on_locacao_id_and_data_evento"
    t.index ["locacao_id"], name: "index_eventos_on_locacao_id"
    t.index ["tipo_evento"], name: "index_eventos_on_tipo_evento"
    t.index ["updated_by_id"], name: "index_eventos_on_updated_by_id"
    t.index ["veiculo_id", "data_evento"], name: "index_eventos_on_veiculo_id_and_data_evento"
    t.index ["veiculo_id", "fluxo", "data_evento"], name: "index_eventos_on_veiculo_id_and_fluxo_and_data_evento"
    t.index ["veiculo_id"], name: "index_eventos_on_veiculo_id"
  end

  create_table "public.locacoes", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.boolean "caucao_devolvida", default: false, null: false
    t.boolean "caucao_recebida", default: false, null: false
    t.decimal "caucao_valor", precision: 12, scale: 2
    t.uuid "cliente_id", null: false
    t.datetime "created_at", null: false
    t.uuid "created_by_id", null: false
    t.date "data_fim"
    t.date "data_inicio", null: false
    t.date "data_prevista_fim", null: false
    t.string "numero_contrato", null: false
    t.text "observacoes"
    t.integer "status", default: 0, null: false
    t.datetime "updated_at", null: false
    t.uuid "updated_by_id", null: false
    t.decimal "valor_semanal", precision: 12, scale: 2, null: false
    t.uuid "veiculo_id", null: false
    t.index ["cliente_id"], name: "index_locacoes_on_cliente_id"
    t.index ["created_by_id"], name: "index_locacoes_on_created_by_id"
    t.index ["numero_contrato"], name: "index_locacoes_on_numero_contrato", unique: true
    t.index ["status"], name: "index_locacoes_on_status"
    t.index ["updated_by_id"], name: "index_locacoes_on_updated_by_id"
    t.index ["veiculo_id"], name: "index_locacoes_on_veiculo_id"
  end

  create_table "public.participacao_socios", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.datetime "created_at", null: false
    t.uuid "created_by_id", null: false
    t.decimal "percentual_participacao", precision: 5, scale: 2, null: false
    t.uuid "socio_id", null: false
    t.datetime "updated_at", null: false
    t.uuid "updated_by_id", null: false
    t.decimal "valor_investido", precision: 12, scale: 2
    t.uuid "veiculo_id", null: false
    t.index ["created_by_id"], name: "index_participacao_socios_on_created_by_id"
    t.index ["socio_id", "veiculo_id"], name: "index_participacao_socios_on_socio_id_and_veiculo_id", unique: true
    t.index ["socio_id"], name: "index_participacao_socios_on_socio_id"
    t.index ["updated_by_id"], name: "index_participacao_socios_on_updated_by_id"
    t.index ["veiculo_id"], name: "index_participacao_socios_on_veiculo_id"
  end

  create_table "public.socios", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.string "cpf", null: false
    t.datetime "created_at", null: false
    t.uuid "created_by_id", null: false
    t.string "email"
    t.string "nome", null: false
    t.string "telefone"
    t.datetime "updated_at", null: false
    t.uuid "updated_by_id", null: false
    t.index ["cpf"], name: "index_socios_on_cpf", unique: true
    t.index ["created_by_id"], name: "index_socios_on_created_by_id"
    t.index ["updated_by_id"], name: "index_socios_on_updated_by_id"
  end

  create_table "public.usuarios", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.boolean "ativo", default: true, null: false
    t.string "cpf", null: false
    t.datetime "created_at", null: false
    t.uuid "created_by_id"
    t.string "email", null: false
    t.string "google_uid"
    t.string "nome", null: false
    t.string "password_digest"
    t.integer "perfil", default: 1, null: false
    t.datetime "updated_at", null: false
    t.uuid "updated_by_id"
    t.index ["cpf"], name: "index_usuarios_on_cpf", unique: true
    t.index ["created_by_id"], name: "index_usuarios_on_created_by_id"
    t.index ["email"], name: "index_usuarios_on_email", unique: true
    t.index ["google_uid"], name: "index_usuarios_on_google_uid", unique: true
    t.index ["updated_by_id"], name: "index_usuarios_on_updated_by_id"
  end

  create_table "public.veiculos", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.integer "ano"
    t.decimal "caucao_retida", precision: 12, scale: 2
    t.string "chassi", null: false
    t.string "cor"
    t.datetime "created_at", null: false
    t.uuid "created_by_id", null: false
    t.date "data_compra"
    t.integer "km_aquisicao"
    t.integer "km_atual"
    t.string "marca"
    t.string "modelo"
    t.string "placa", null: false
    t.date "primeira_locacao_em"
    t.string "renavam", null: false
    t.integer "status", default: 0, null: false
    t.integer "tipo_manutencao_programada"
    t.datetime "updated_at", null: false
    t.uuid "updated_by_id", null: false
    t.decimal "valor_aquisicao", precision: 12, scale: 2
    t.decimal "valor_compra", precision: 12, scale: 2
    t.decimal "valor_diaria", precision: 12, scale: 2
    t.decimal "valor_semanal", precision: 12, scale: 2
    t.index ["chassi"], name: "index_veiculos_on_chassi", unique: true
    t.index ["created_by_id"], name: "index_veiculos_on_created_by_id"
    t.index ["placa"], name: "index_veiculos_on_placa", unique: true
    t.index ["renavam"], name: "index_veiculos_on_renavam", unique: true
    t.index ["status"], name: "index_veiculos_on_status"
    t.index ["updated_by_id"], name: "index_veiculos_on_updated_by_id"
  end

  add_foreign_key "public.anexos", "public.eventos"
  add_foreign_key "public.anexos", "public.usuarios", column: "created_by_id"
  add_foreign_key "public.anexos", "public.usuarios", column: "updated_by_id"
  add_foreign_key "public.anexos", "public.veiculos"
  add_foreign_key "public.auditoria_logs", "public.usuarios"
  add_foreign_key "public.auditoria_logs", "public.veiculos"
  add_foreign_key "public.clientes", "public.usuarios", column: "created_by_id"
  add_foreign_key "public.clientes", "public.usuarios", column: "updated_by_id"
  add_foreign_key "public.eventos", "public.clientes"
  add_foreign_key "public.eventos", "public.locacoes"
  add_foreign_key "public.eventos", "public.usuarios", column: "created_by_id"
  add_foreign_key "public.eventos", "public.usuarios", column: "updated_by_id"
  add_foreign_key "public.eventos", "public.veiculos"
  add_foreign_key "public.locacoes", "public.clientes"
  add_foreign_key "public.locacoes", "public.usuarios", column: "created_by_id"
  add_foreign_key "public.locacoes", "public.usuarios", column: "updated_by_id"
  add_foreign_key "public.locacoes", "public.veiculos"
  add_foreign_key "public.participacao_socios", "public.socios"
  add_foreign_key "public.participacao_socios", "public.usuarios", column: "created_by_id"
  add_foreign_key "public.participacao_socios", "public.usuarios", column: "updated_by_id"
  add_foreign_key "public.participacao_socios", "public.veiculos"
  add_foreign_key "public.socios", "public.usuarios", column: "created_by_id"
  add_foreign_key "public.socios", "public.usuarios", column: "updated_by_id"
  add_foreign_key "public.usuarios", "public.usuarios", column: "created_by_id"
  add_foreign_key "public.usuarios", "public.usuarios", column: "updated_by_id"
  add_foreign_key "public.veiculos", "public.usuarios", column: "created_by_id"
  add_foreign_key "public.veiculos", "public.usuarios", column: "updated_by_id"

end

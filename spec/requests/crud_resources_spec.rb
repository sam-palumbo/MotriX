require "rails_helper"

RSpec.describe "CRUD resources", type: :request do
  let(:admin) { create(:usuario, :admin) }

  before do
    login_as(admin)
  end

  resources = {
    clientes: {
      model: Cliente,
      factory: :cliente,
      valid_attributes: -> { attributes_for(:cliente).slice(:cpf, :nome, :telefone, :email, :endereco, :cidade, :estado, :cep, :cnh, :validade_cnh, :status, :observacoes) },
      update_attributes: -> { { nome: "Cliente Atualizado", telefone: "11999999999" } },
      invalid_attributes: -> { { nome: nil, cpf: nil } }
    },
    veiculos: {
      model: Veiculo,
      factory: :veiculo,
      valid_attributes: -> { attributes_for(:veiculo).slice(:placa, :renavam, :chassi, :marca, :modelo, :ano, :cor, :data_compra, :valor_compra, :valor_aquisicao, :valor_semanal, :valor_diaria, :km_aquisicao, :km_atual, :status, :primeira_locacao_em, :caucao_retida) },
      update_attributes: -> { { marca: "Honda", modelo: "CG 160" } },
      invalid_attributes: -> { { placa: nil, renavam: nil, chassi: nil } }
    },
    locacoes: {
      model: Locacao,
      factory: :locacao,
      valid_attributes: -> {
        cliente = create(:cliente)
        veiculo = create(:veiculo)
        attributes_for(:locacao).slice(:numero_contrato, :data_inicio, :data_prevista_fim, :data_fim, :valor_semanal, :caucao_valor, :caucao_recebida, :caucao_devolvida, :status, :observacoes).merge(
          cliente_id: cliente.id,
          veiculo_id: veiculo.id
        )
      },
      update_attributes: -> { { observacoes: "Contrato revisado", valor_semanal: 425.50 } },
      invalid_attributes: -> { { numero_contrato: nil, data_inicio: nil, data_prevista_fim: nil, valor_semanal: nil } },
      before_form: -> { create(:cliente, nome: "Cliente Form"); create(:veiculo, placa: "FORM123") }
    },
    eventos: {
      model: Evento,
      factory: :evento,
      record: -> { create(:evento, tipo_evento: :gasto_empresa, fluxo: :saida) },
      valid_attributes: -> {
        {
          tipo_evento: Evento.tipo_eventos[:gasto_empresa],
          fluxo: Evento.fluxos[:saida],
          status: Evento.statuses[:pago],
          valor: 150.75,
          responsavel: admin.nome,
          descricao: "Despesa operacional",
          data_evento: Date.current
        }
      },
      update_attributes: -> { { descricao: "Descricao atualizada", valor: 175.25 } },
      invalid_attributes: -> { { tipo_evento: nil, fluxo: nil, valor: nil, responsavel: nil, data_evento: nil } },
      before_form: -> { create(:cliente, nome: "Cliente Evento"); create(:veiculo, placa: "EVT123"); create(:locacao) }
    },
    socios: {
      model: Socio,
      factory: :socio,
      valid_attributes: -> { attributes_for(:socio).slice(:cpf, :nome, :telefone, :email) },
      update_attributes: -> { { nome: "Socio Atualizado", telefone: "11888888888" } },
      invalid_attributes: -> { { nome: nil, cpf: nil } }
    },
    usuarios: {
      model: Usuario,
      factory: :usuario,
      valid_attributes: -> {
        attributes_for(:usuario).slice(:cpf, :nome, :email, :password, :password_confirmation, :perfil, :ativo)
      },
      update_attributes: -> { { nome: "Usuario Atualizado", ativo: false } },
      invalid_attributes: -> { { nome: nil, cpf: nil, email: nil, password: nil } }
    },
    participacao_socios: {
      model: ParticipacaoSocio,
      factory: :participacao_socio,
      valid_attributes: -> {
        socio = create(:socio)
        veiculo = create(:veiculo)
        {
          socio_id: socio.id,
          veiculo_id: veiculo.id,
          percentual_participacao: 25.5,
          valor_investido: 10_000
        }
      },
      update_attributes: -> { { percentual_participacao: 35.25, valor_investido: 12_500 } },
      invalid_attributes: -> { { socio_id: nil, veiculo_id: nil, percentual_participacao: nil } },
      before_form: -> { create(:socio, nome: "Socio Form"); create(:veiculo, placa: "PAR123") }
    }
  }

  resources.each do |resource_name, config|
    singular_route = resource_name.to_s.singularize
    param_key = config[:model].model_name.param_key

    describe resource_name.to_s do
      def run_setup(config)
        instance_exec(&config[:before_form]) if config[:before_form]
      end

      def attrs_from(config, key)
        instance_exec(&config.fetch(key))
      end

      def create_record(config)
        config[:record] ? instance_exec(&config[:record]) : create(config[:factory])
      end

      it "renders index" do
        create_record(config)

        get public_send("#{resource_name}_path")

        expect(response).to have_http_status(:ok)
      end

      it "renders show" do
        record = create_record(config)

        get public_send("#{singular_route}_path", record)

        expect(response).to have_http_status(:ok)
      end

      it "renders new" do
        run_setup(config)

        get public_send("new_#{singular_route}_path")

        expect(response).to have_http_status(:ok)
      end

      it "renders edit" do
        run_setup(config)
        record = create_record(config)

        get public_send("edit_#{singular_route}_path", record)

        expect(response).to have_http_status(:ok)
      end

      it "creates with valid attributes" do
        expect {
          post public_send("#{resource_name}_path"), params: { param_key => attrs_from(config, :valid_attributes) }
        }.to change(config[:model], :count).by(1)

        expect(response).to redirect_to(public_send("#{singular_route}_path", config[:model].order(:created_at).last))
      end

      it "rejects invalid create attributes" do
        expect {
          post public_send("#{resource_name}_path"), params: { param_key => attrs_from(config, :invalid_attributes) }
        }.not_to change(config[:model], :count)

        expect(response).to have_http_status(:unprocessable_content)
      end

      it "updates with valid attributes" do
        record = create_record(config)

        patch public_send("#{singular_route}_path", record), params: { param_key => attrs_from(config, :update_attributes) }

        expect(response).to redirect_to(public_send("#{singular_route}_path", record))
      end

      it "rejects invalid update attributes" do
        record = create_record(config)

        patch public_send("#{singular_route}_path", record), params: { param_key => attrs_from(config, :invalid_attributes) }

        expect(response).to have_http_status(:unprocessable_content)
      end

      it "destroys the record" do
        record = create_record(config)

        expect {
          delete public_send("#{singular_route}_path", record)
        }.to change(config[:model], :count).by(-1)

        expect(response).to redirect_to(public_send("#{resource_name}_path"))
      end
    end
  end
end

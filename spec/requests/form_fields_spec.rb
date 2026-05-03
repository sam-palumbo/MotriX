require "rails_helper"

RSpec.describe "Resource form fields", type: :request do
  let(:admin) { create(:usuario, :admin) }

  before do
    login_as(admin)
  end

  exact_forms = {
    clientes: {
      factory: :cliente,
      fields: %i[cpf nome telefone email endereco cidade estado cep cnh validade_cnh status observacoes]
    },
    veiculos: {
      factory: :veiculo,
      fields: %i[placa renavam chassi marca modelo ano cor data_compra valor_compra valor_aquisicao valor_semanal valor_diaria km_aquisicao km_atual status primeira_locacao_em caucao_retida]
    },
    locacoes: {
      factory: :locacao,
      fields: %i[numero_contrato cliente_id veiculo_id data_inicio data_prevista_fim data_fim valor_semanal caucao_valor caucao_recebida caucao_devolvida status observacoes],
      setup: -> { create(:cliente); create(:veiculo) }
    },
    socios: {
      factory: :socio,
      fields: %i[cpf nome telefone email]
    },
    participacao_socios: {
      factory: :participacao_socio,
      fields: %i[socio_id veiculo_id percentual_participacao valor_investido],
      setup: -> { create(:socio); create(:veiculo) }
    }
  }

  exact_forms.each do |resource_name, config|
    singular_route = resource_name.to_s.singularize
    param_key = resource_name.to_s.singularize
    param_key = "participacao_socio" if resource_name == :participacao_socios

    describe resource_name.to_s do
      it "renders only the expected new form fields" do
        instance_exec(&config[:setup]) if config[:setup]

        get public_send("new_#{singular_route}_path")

        expect(response).to have_http_status(:ok)
        expect_form_fields_only_for(param_key, config[:fields])
      end

      it "renders only the expected edit form fields" do
        instance_exec(&config[:setup]) if config[:setup]
        record = create(config[:factory])

        get public_send("edit_#{singular_route}_path", record)

        expect(response).to have_http_status(:ok)
        expect_form_fields_only_for(param_key, config[:fields])
      end
    end
  end

  describe "usuarios" do
    it "renders expected new form fields" do
      get new_usuario_path

      expect(response).to have_http_status(:ok)
      expect_form_fields_only_for("usuario", %i[nome cpf email password password_confirmation perfil ativo])
    end

    it "renders expected edit form fields" do
      usuario = create(:usuario)

      get edit_usuario_path(usuario)

      expect(response).to have_http_status(:ok)
      expect_form_fields_only_for("usuario", %i[nome cpf email password perfil ativo])
    end
  end

  describe "eventos" do
    before do
      create(:cliente)
      create(:veiculo)
      create(:locacao)
    end

    it "renders core event fields on the new form" do
      get new_evento_path

      expect(response).to have_http_status(:ok)
      expect_form_fields_for("evento", %i[cliente_id veiculo_id locacao_id tipo_evento fluxo status valor data_evento responsavel tipo_manutencao quilometragem periodo_inicio periodo_fim descricao])
      expect(form_control_names).to include("evento[anexos][]", "anexos[categoria]")
    end

    it "renders core event fields on the edit form" do
      evento = create(:evento, :manutencao)

      get edit_evento_path(evento)

      expect(response).to have_http_status(:ok)
      expect_form_fields_for("evento", %i[cliente_id veiculo_id locacao_id tipo_evento fluxo status valor data_evento responsavel tipo_manutencao quilometragem periodo_inicio periodo_fim descricao])
    end
  end
end

# frozen_string_literal: true

AuditoriaLog.delete_all
Anexo.delete_all
Evento.delete_all
Locacao.delete_all
ParticipacaoSocio.delete_all
Socio.delete_all
Veiculo.delete_all
Cliente.delete_all
Usuario.delete_all

admin = Usuario.create!(
  cpf: "11122233344",
  nome: "Administrador MotriX",
  email: "admin@motrix.local",
  senha_hash: "trocar-esta-senha",
  perfil: :admin,
  ativo: true
)

operador = Usuario.create!(
  cpf: "55566677788",
  nome: "Operador MotriX",
  email: "operador@motrix.local",
  senha_hash: "trocar-esta-senha",
  perfil: :operador,
  ativo: true,
  created_by: admin,
  updated_by: admin
)

cliente = Cliente.create!(
  cpf: "12345678900",
  nome: "Carlos Silva",
  telefone: "(11) 98888-0001",
  email: "carlos@example.com",
  endereco: "Rua das Palmeiras, 123",
  cidade: "Sao Paulo",
  estado: "SP",
  cep: "01000-000",
  cnh: "12345678901",
  validade_cnh: 2.years.from_now.to_date,
  status: :ativo,
  observacoes: "Cliente recorrente",
  created_by: admin,
  updated_by: admin
)

veiculo = Veiculo.create!(
  placa: "ABC1D23",
  renavam: "12345678901",
  chassi: "9BWZZZ377VT004251",
  marca: "Honda",
  modelo: "CG 160",
  ano: 2024,
  cor: "Preta",
  data_compra: Date.current - 120.days,
  valor_compra: 18_900,
  valor_aquisicao: 18_400,
  valor_semanal: 420,
  valor_diaria: 75,
  km_aquisicao: 1200,
  km_atual: 5400,
  status: :locado,
  primeira_locacao_em: Date.current - 90.days,
  caucao_retida: 1000,
  created_by: admin,
  updated_by: admin
)

socio = Socio.create!(
  cpf: "99988877766",
  nome: "Marina Costa",
  telefone: "(11) 97777-0002",
  email: "marina@example.com",
  created_by: admin,
  updated_by: admin
)

ParticipacaoSocio.create!(
  socio: socio,
  veiculo: veiculo,
  percentual_participacao: 50,
  valor_investido: 9_200,
  created_by: admin,
  updated_by: admin
)

locacao = Locacao.create!(
  numero_contrato: "LOC-2026-0001",
  cliente: cliente,
  veiculo: veiculo,
  data_inicio: Date.current - 21.days,
  data_prevista_fim: Date.current + 14.days,
  valor_semanal: 420,
  caucao_valor: 1000,
  caucao_recebida: true,
  caucao_devolvida: false,
  status: :ativa,
  observacoes: "Pagamento toda segunda-feira",
  created_by: operador,
  updated_by: operador
)

Evento.create!(
  cliente: cliente,
  veiculo: veiculo,
  locacao: locacao,
  tipo_evento: :pagamento_semanal,
  fluxo: :entrada,
  status: :pago,
  valor: 420,
  periodo_inicio: Date.current - 7.days,
  periodo_fim: Date.current - 1.day,
  responsavel: operador.nome,
  descricao: "Pagamento da semana anterior",
  data_evento: Date.current - 1.day,
  created_by: operador,
  updated_by: operador
)

AuditoriaLog.create!(
  usuario: operador,
  veiculo: veiculo,
  acao: "seed_inicial",
  tipo_evento: "pagamento_semanal",
  valor: 420,
  detalhes: "Base inicial criada para demonstracao",
  created_at: Time.current
)

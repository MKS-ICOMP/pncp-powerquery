let
    // 1. Busca os editais encerrados via API de Busca
    UrlBusca = "https://pncp.gov.br/api/search/?q=CorelDRAW&tipos_documento=edital&status=encerradas&data_inicial=20230917&data_final=20260917&pagina=1&tam_pagina=10000",
    Fonte = Json.Document(Web.Contents(UrlBusca)),
    ItensBusca = Fonte[items],
    TabelaEditais = Table.FromList(ItensBusca, Splitter.SplitByNothing(), null, null, ExtraValues.Error),

    // 2. Extrai dados chave para chamar o endpoint estruturado
    EditaisExpandidos = Table.ExpandRecordColumn(
        TabelaEditais, 
        "Column1", 
        {"numero_controle_pncp", "orgao_cnpj", "ano", "numero_sequencial", "orgao_nome", "uf", "item_url"}
    ),

    // 3. Função que chama a API estruturada do Swagger para buscar os itens
    BuscarItensPncp = (cnpj as text, ano as text, seq as text) =>
        let
            UrlItens = "https://pncp.gov.br/api/pncp/v1/orgaos/" & cnpj & "/compras/" & ano & "/" & seq & "/itens?pagina=1&tamanhoPagina=100",
            // Usa try/otherwise para ignorar eventuais compras sem itens cadastrados ou erros 404
            Requisicao = try Json.Document(Web.Contents(UrlItens)) otherwise null
        in
            Requisicao,

    // 4. Adiciona a coluna chamando a API estruturada para cada edital
    AdicionarItens = Table.AddColumn(
        EditaisExpandidos, 
        "DadosItens", 
        each BuscarItensPncp([orgao_cnpj], [ano], [numero_sequencial])
    ),

    // Filtra apenas contratações que retornaram itens válidos
    FiltrarValidos = Table.SelectRows(AdicionarItens, each [DadosItens] <> null and [DadosItens] is list),

    // 5. Expande a lista de itens em novas linhas (1 linha por item de compra)
    ItensEmLinhas = Table.ExpandListColumn(FiltrarValidos, "DadosItens"),

    // 6. Expande as propriedades detalhadas do item obtidas no Swagger
    ItensDetalhados = Table.ExpandRecordColumn(
        ItensEmLinhas, 
        "DadosItens", 
        {
            "numeroItem", 
            "descricao", 
            "quantidade", 
            "unidadeMedida", 
            "valorUnitarioEstimado", 
            "valorUnitarioHomologado", 
            "valorTotal"
        }, 
        {
            "numero_item", 
            "item_descricao", 
            "quantidade", 
            "unidade_medida", 
            "valor_unitario_estimado", 
            "valor_unitario_homologado", 
            "valor_total_estimado"
        }
    ),

    // 7. Define o valor unitário efetivamente contratado (adota o homologado; caso nulo, o estimado)
    AdicionarValorContratado = Table.AddColumn(
        ItensDetalhados, 
        "valor_unitario_efetivamente_contratado", 
        each if [valor_unitario_homologado] <> null and [valor_unitario_homologado] > 0 
             then [valor_unitario_homologado] 
             else [valor_unitario_estimado], 
        type number
    ),

    // 8. Tipagem dos campos
    TipagemFinal = Table.TransformColumnTypes(AdicionarValorContratado, {
        {"numero_item", Int64.Type},
        {"item_descricao", type text},
        {"quantidade", type number},
        {"unidade_medida", type text},
        {"valor_unitario_estimado", type number},
        {"valor_unitario_homologado", type number},
        {"valor_total_estimado", type number},
        {"valor_unitario_efetivamente_contratado", type number},
        {"orgao_cnpj", type text},
        {"ano", type text},
        {"numero_sequencial", type text}
    })
in
    TipagemFinal
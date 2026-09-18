# PNCP Power Query - Extrator de Compras e Preços Públicos

Script em **Linguagem M (Power Query)** para **Microsoft Excel** e **Microsoft Power BI** que integra diretamente com a API pública do **Portal Nacional de Contratações Públicas (PNCP)** do Governo Federal brasileiro.

O script realiza a busca de editais/contratações com base em palavras-chave e consulta recursivamente o detalhamento de cada item licitado, extraindo quantidades, valores unitários estimados, valores homologados (vencedores) e calculando o preço efetivamente contratado.

---

## 📌 Funcionalidades

- **Busca Direta na API de Pesquisa do PNCP**: Localiza contratações públicas encerradas por palavra-chave e período definido.
- **Detalhamento Automatizado dos Itens**: Para cada edital retornado, faz uma requisição ao endpoint estruturado da API do PNCP para buscar todos os itens da compra.
- **Tratamento de Exceções**: Utiliza blocos `try ... otherwise` para ignorar compras sem itens ou eventuais respostas nulas/erros de requisição, evitando interrupção da carga.
- **Cálculo de Preço Efetivo**: Criação automática da coluna `valor_unitario_efetivamente_contratado`, priorizando o preço homologado (vencedor da licitação) e utilizando o estimado como fallback.
- **Tipagem de Dados Pronta**: Converte campos em tipos nativos (`number`, `Int64.Type`, `text`), facilitando análises imediatas com Tabelas Dinâmicas, fórmulas e gráficos.

---

## 📂 Estrutura do Repositório

```text
├── consulta.m       # Código-fonte da consulta em Linguagem M (Power Query)
└── README.md        # Documentação e guia de uso
```

---

## 🚀 Como Utilizar

### No Microsoft Excel

1. Abra o **Microsoft Excel** e crie uma nova pasta de trabalho.
2. Na barra de ferramentas superior, acesse a guia **Dados**.
3. Clique em **Obter Dados** > **De Outras Fontes** > **Consulta em Branco**.
4. Na janela do Editor do Power Query que se abrirá, clique no botão **Editor Avançado** (guia *Página Inicial* ou *Exibição*).
5. Substitua todo o conteúdo existente pelo código do arquivo [`consulta.m`](./consulta.m).
6. Clique em **Concluído**.
7. *(Se solicitado)*: Ao carregar os dados da web, o Excel pode solicitar o nível de privacidade para a URL `pncp.gov.br`:
   - Selecione **Anônimo** para o tipo de autenticação.
   - Defina o nível de privacidade como **Público** (ou *Organizacional*).
8. Clique em **Fechar e Carregar** para exportar os dados estruturados diretamente para uma planilha do Excel.

### No Microsoft Power BI Desktop

1. Abra o **Power BI Desktop**.
2. Na guia **Página Inicial**, clique em **Transformar Dados** para abrir o Editor do Power Query.
3. No painel de consultas à esquerda, clique com o botão direito e selecione **Nova Consulta** > **Consulta em Branco**.
4. Clique em **Editor Avançado**.
5. Cole o código de [`consulta.m`](./consulta.m) e clique em **Concluído**.
6. Clique em **Fechar e Aplicar**.

---

## 📊 Colunas Geradas na Tabela Final

| Coluna | Tipo | Descrição |
|---|---|---|
| `numero_controle_pncp` | Texto | Identificador único do edital no PNCP |
| `orgao_cnpj` | Texto | CNPJ do órgão contratante |
| `ano` | Texto | Ano da contratação |
| `numero_sequencial` | Texto | Sequencial da compra do órgão |
| `orgao_nome` | Texto | Razão social / nome do órgão público |
| `uf` | Texto | Unidade da Federação do órgão |
| `item_url` | Texto | Link de consulta da contratação no portal PNCP |
| `numero_item` | Inteiro | Número ordinal do item dentro da licitação |
| `item_descricao` | Texto | Descrição completa do produto/serviço licitado |
| `quantidade` | Número | Quantidade demandada do item |
| `unidade_medida` | Texto | Unidade de medida (ex: Unidade, Licença, Caixa) |
| `valor_unitario_estimado` | Número | Preço unitário de referência estipulado pelo órgão |
| `valor_unitario_homologado` | Número | Preço unitário final vencedor/adjudicado |
| `valor_total_estimado` | Número | Preço total estimado do lote/item |
| `valor_unitario_efetivamente_contratado` | Número | Valor homologado (se > 0) ou valor estimado |

---

## ⚙️ Personalização da Consulta

No arquivo [`consulta.m`](./consulta.m), na **Linha 3**, você pode alterar a URL da consulta para pesquisar outros termos e intervalos de datas:

```powerquery
UrlBusca = "https://pncp.gov.br/api/search/?q=CorelDRAW&tipos_documento=edital&status=encerradas&data_inicial=20230917&data_final=20260917&pagina=1&tam_pagina=10000"
```

### Parâmetros configuráveis:
- **`q`**: Termo ou produto a pesquisar (ex: `q=AutoCAD`, `q=Microsoft+365`, `q=Notebook`).
- **`status`**: Situação da compra (ex: `encerradas` para contratações finalizadas).
- **`data_inicial` / `data_final`**: Período no formato `AAAAMMDD` (ex: `20240101` a `20241231`).
- **`tam_pagina`**: Quantidade máxima de editais retornados (padrão `10000`).

> [!TIP]
> Você pode transformar o termo `q` em um **Parâmetro do Power Query**, permitindo que qualquer usuário do Excel ou Power BI digite o termo desejado em uma caixa de texto sem precisar editar o código M.

---

## 🌐 Referência das APIs Utilizadas

- **Portal Nacional de Contratações Públicas (PNCP)**: [pncp.gov.br](https://pncp.gov.br)
- **API de Busca**: `https://pncp.gov.br/api/search/`
- **API Estruturada / Swagger**: `https://pncp.gov.br/api/pncp/v1/`

---

## 📄 Licença

Este projeto é distribuído sob a licença [MIT](https://opensource.org/licenses/MIT). Sinta-se livre para utilizar, modificar e distribuir.


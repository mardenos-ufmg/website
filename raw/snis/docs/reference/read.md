<div id="main" class="col-md-9" role="main">

# Ler CSV do SNIS

<div class="ref-description section level2">

Ler CSV do SNIS

</div>

<div class="section level2">

## Usage

<div class="sourceCode">

``` r
read(ano)
```

</div>

</div>

<div class="section level2">

## Arguments

-   ano:

    inteiro entre 2000 e 2022

</div>

<div class="section level2">

## Value

tibble

</div>

<div class="section level2">

## Origem dos dados

Os dados foram retirados de
`https://app4.cidades.gov.br/serieHistorica/` com as seguintes opções:

-   Informações e indicadores desagregados;

-   Ano de referẽncia: `ano`;

-   Região: `Sudeste`;

-   Estado: `Minas Gerais`;

-   Demais filtros: `Marcar todos`.

</div>

<div class="section level2">

## Estrutura do CSV

Por meio da função `readr::guess_encoding()` podemos ver que a
codificação dos CSVs é `UTF-16LE`.

As colunas são separadas por `;` e possuem um `;` extra ao final de cada
linha, o que pode produzir uma coluna extra a depender da forma como
esse arquivo é lido. Isso foi evitado aqui por meio da exclusão do
último caractere de cada durante a leitra do CSV.

A última linha - que originalmente continha valores totais das variáveis
da amostra - foi excluída.

Para os números, o separador decimal original era a vírgula e o de
centenas, o ponto.

</div>

<div class="section level2">

## Estilo

Optamos por manter acentos e diacríticos (como o til) no nome das
colunas, mas o nome de todas as colunas foi passada para caracteres
minúsculos. Originalmente, a descrição de cada variável estava no
pŕoprio nome da coluna, após um travessão `-`, mas aqui optamos por
excluir tudo o que vinha depois disso. A descrição das variáveis está
disponível na vinheta
[`dados`](https://mardenos-ufmg.github.io/snis/articles/dados.html).

</div>

<div class="section level2">

## IBGE

Originalmente, o `código do município` no CSV não continha o último
dígito de verificação. Optamos por colocar esse último dígito, conforme
padrão do IBGE. Ainda de acordo com o IBGE, as colunas referentes à
`região intermediária` e à `região imediata` foram adicionadas.

</div>

</div>

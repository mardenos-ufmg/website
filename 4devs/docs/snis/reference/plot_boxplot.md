<div id="main" class="col-md-9" role="main">

# Boxplots Scores por Grupos

<div class="ref-description section level2">

Essa função gera um boxplot que mostra a distribuição de uma variável de
*score* em diferentes grupos (como prestadores, regiões ou naturezas
jurídicas).

</div>

<div class="section level2">

## Usage

<div class="sourceCode">

``` r
plot_boxplot(df, var, group, titulo = NULL, paleta = "plasma")
```

</div>

</div>

<div class="section level2">

## Arguments

-   df:

    Data frame contendo os dados.

-   var:

    Vetor de strings com os nomes das colunas que contêm os scores, como
    `score médio su`, `score médio eee`.

-   group:

    Vetor de strings com os nomes das colunas de agrupamento, como
    `natureza jurídica`.

-   titulo:

    (opcional) Título do gráfico. Se `NULL`, é gerado automaticamente

-   paleta:

    (opcional) Paleta de cores viridis a ser usada. Opções: `"viridis"`,
    `"plasma"`, `"magma"`, `"cividis"`, `"inferno"`. Padrão: `"plasma"`.

</div>

<div class="section level2">

## Value

Um objeto `ggplot` contendo o boxplot formatado.

</div>

</div>

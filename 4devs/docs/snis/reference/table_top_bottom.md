<div id="main" class="col-md-9" role="main">

# Tabela dos Melhores e Piores municípios

<div class="ref-description section level2">

Exibe uma tabela cos os Melhores e Piores Municípios com base no Score
Médio das categorias.

</div>

<div class="section level2">

## Usage

<div class="sourceCode">

``` r
table_top_bottom(df, top_n, bottom_n)
```

</div>

</div>

<div class="section level2">

## Arguments

-   df:

    Data frame contendo os dados.

-   top_n:

    Número de municípios com maiores *scores médios* a serem listados.

-   bottom_n:

    Número de municípios com menores *scores médios* a serem listados.

</div>

<div class="section level2">

## Value

Uma lista com dois elementos:

-   `Melhores`: data frame com os municípios com maiores *scores
    médios*;

-   `Piores`: data frame com os municípios com menores *scores médios*.

</div>

</div>

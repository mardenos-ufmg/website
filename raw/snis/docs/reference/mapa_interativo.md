<div id="main" class="col-md-9" role="main">

# Mapa interativo de Scores por Região

<div class="ref-description section level2">

Gera um mapa interativo mostrando a distribuição de um score por região,
colorindo os municípios de acordo com quartis do score.

</div>

<div class="section level2">

## Usage

<div class="sourceCode">

``` r
mapa_interativo(df, var, quart = FALSE, titulo = NULL)
```

</div>

</div>

<div class="section level2">

## Arguments

-   df:

    Data frame contendo os dados.

-   var:

    String com o nome da coluna que contém o score, como
    `"score médio su"`.

-   quart:

    (opcional) Lógico. Se `TRUE`, colore os municípios por **quartis**
    do score; se `FALSE` (padrão), usa os valores contínuos.

-   titulo:

    (opcional) Título do mapa. Se `NULL`, é gerado automaticamente com
    base no nome da coluna de score.

</div>

<div class="section level2">

## Value

Um objeto `tmap` interativo com os municípios coloridos por quartis do
score.

</div>

</div>

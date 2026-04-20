<div id="main" class="col-md-9" role="main">

# Histograma com curva de densidade

<div class="ref-description section level2">

Cria um histograma com a curva de densidade sobreposta, permitindo
visualizar simultaneamente a frequência e a distribuição suave.

</div>

<div class="section level2">

## Usage

<div class="sourceCode">

``` r
plot_hist(df, var, titulo = NULL)
```

</div>

</div>

<div class="section level2">

## Arguments

-   df:

    Data frame contendo os dados.

-   var:

    String com o nome da coluna numérica a ser analisada, como
    `"IN023"`.

-   titulo:

    (opcional) Título do gráfico. Se `NULL`, é gerado automaticamente.

</div>

<div class="section level2">

## Value

Um objeto `ggplot` com o histograma e a curva de densidade.

</div>

</div>

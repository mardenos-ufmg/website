<div id="main" class="col-md-9" role="main">

# Análise Fatorial para dados do SNIS

<div class="ref-description section level2">

Função geradora dos scores e loadings da análise fatorial com dados do
SINS

</div>

<div class="section level2">

## Usage

<div class="sourceCode">

``` r
fa(df, grupos, normalizar = T, rotacao = "oblimin")
```

</div>

</div>

<div class="section level2">

## Arguments

-   df:

    data.frame com dados para análise fatorial

-   grupos:

    data.frame com esquema de grupos para a análise fatorial, pode ser
    passada string 'eee' ou 'su'

-   normalizar:

    lógico, `TRUE` (padrão) se os scores devem ser padronizados, `FALSE`
    se não.

-   rotacao:

    string, tipo de rotação a ser usada no argumento `rotate` da função
    `psych::fa()`, o padrão é 'oblimin'

</div>

<div class="section level2">

## Value

objeto do tipo `fa-snis`, uma lista contendo os scores e loadings de
cada grupo

</div>

<div class="section level2">

## Grupos

O argumento grupos deve ser um data.frame contendo as colunas.

</div>

</div>

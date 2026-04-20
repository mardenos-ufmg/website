<div id="main" class="col-md-9" role="main">

# Teste de Barlett

<div class="ref-description section level2">

O objetivo dessa função é verificar se os dados são adequados para uma
Análise Fatorial, isto é, se há correlação entre as variáveis.

</div>

<div class="section level2">

## Usage

<div class="sourceCode">

``` r
bartlett(df, alpha = 0.05)
```

</div>

</div>

<div class="section level2">

## Arguments

-   df:

    data.frame com dados

-   alpha:

    número entre zero e um; nível de significancia aceito; o padrão é
    0.05.

</div>

<div class="section level2">

## Value

`TRUE` se há dependência entre os dados ou `FALSE` se não há (logo não
faz sentido uma Análise Fatorial), é possível retornar `NA` se não há
linhas completas.

</div>

<div class="section level2">

## Tipo de correlação

Para computar a matriz de covarância escolhemos o tipo `na.or.complete`,
que considera apenas as linha completas (sem `NA`) de `df`. Se não
houver linhas completas, o valor retornado será um `NA`. Originalmente
usava-se o `pairwise.complete.obs`, mas isso pode retornar matrizes de
correlçao com autoravalores negativos, o que não é adequado. Esses
métodos de computação da matriz de covariância estão disponíveis no
argumento `use` da função `stats::cor`.

</div>

</div>

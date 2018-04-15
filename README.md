
<!-- README.md is generated from README.Rmd. Please edit that file -->
gainr
=====

The goal of gainr is to create gain charts for use in evaluating classification models on large datasets. In applications with a large number of subjecs, one is often only interested in the subjects which are among the ones with the highest predicted probability. These may be the targets of, e.g., retention efforts or direct marketing. With large datasets, the number of groups used in the gain charts may be in the hundreds or more, and such gain charts may be hard to visualize using the gains package. gainr extends gains by converting its returned object to a tibble, which allows downstream use of the gain chart, e.g., plotting, or exporting to csv.

All underlying computations in gainr are done using the [gains](https://cran.r-project.org/package=gains) package, which is available on CRAN.

Installation
------------

You can install gainr from github with:

``` r
# install.packages("devtools")
devtools::install_github("osorensen/gainr")
```

Example
-------

This example uses the diamonds dataset in the ggplot2 package to create a classification model. The goal is to predict whether a diamonds is more or less than 1 carat

``` r
library(dplyr)
library(ggplot2)
# Splitting into a training and test set
train_inds <- sample(floor(nrow(diamonds)/2))
test_inds <- setdiff(1:nrow(diamonds), train_inds)

training_data <- diamonds %>% 
  slice(train_inds) %>% 
  mutate(label = (carat > 1))

test_data <- diamonds %>% 
  slice(test_inds) %>% 
  mutate(label = (carat > 1))
```

Training a logistic regression model on the training set, and predicting on the test set.

``` r
log_model <- glm(label ~ cut + color + clarity + depth + table, 
                 family = binomial(), data = training_data)

# Now predict on the test set
predictions <- predict(log_model, newdata = test_data, type = "response")
```

Finally create a gain chart. The gain chart df1 has 10 groups, with about 2700 observations in each

``` r
library(gainr)
df1 <- get_gain_chart(actual = test_data$label, predicted = predictions)
#> Converting the vector of actuals to numeric
df1
#> # A tibble: 10 x 11
#>    depth   obs cume.obs mean.resp cume.mean.resp cume.pct.of.total  lift
#>    <dbl> <int>    <int>     <dbl>          <dbl>             <dbl> <dbl>
#>  1   10.  2698     2698   0.105           0.105              0.378  378.
#>  2   20.  2699     5397   0.0563          0.0806             0.581  203.
#>  3   30.  2694     8091   0.0371          0.0661             0.714  134.
#>  4   40.  2704    10795   0.0196          0.0545             0.785   71.
#>  5   50.  2692    13487   0.0130          0.0462             0.832   47.
#>  6   60.  2700    16187   0.0133          0.0407             0.880   48.
#>  7   70.  2692    18879   0.00892         0.0362             0.912   32.
#>  8   80.  2697    21576   0.00890         0.0328             0.944   32.
#>  9   90.  2697    24273   0.00742         0.0300             0.971   27.
#> 10  100.  2697    26970   0.00816         0.0278             1.00    29.
#> # ... with 4 more variables: cume.lift <dbl>, mean.prediction <dbl>,
#> #   min.prediction <dbl>, max.prediction <dbl>
```

If we instead want to focus only on the subject with the highest predicted probabilities, we might set the groups argument to, say 3000.

``` r
df2 <- get_gain_chart(actual = test_data$label, predicted = predictions,
                      groups = 3000)
#> Converting the vector of actuals to numeric
df2
#> # A tibble: 2,919 x 11
#>    depth   obs cume.obs mean.resp cume.mean.resp cume.pct.of.total  lift
#>    <dbl> <int>    <int>     <dbl>          <dbl>             <dbl> <dbl>
#>  1    0.     8        8     0.500          0.500           0.00534 1800.
#>  2    0.     9       17     0.333          0.412           0.00935 1200.
#>  3    0.     9       26     0.333          0.385           0.0134  1200.
#>  4    0.     9       35     0.222          0.343           0.0160   800.
#>  5    0.     9       44     0.333          0.341           0.0200  1200.
#>  6    0.     9       53     0.444          0.358           0.0254  1600.
#>  7    0.     9       62     0.333          0.355           0.0294  1200.
#>  8    0.     9       71     0.222          0.338           0.0320   800.
#>  9    0.     9       80     0.333          0.338           0.0360  1200.
#> 10    0.     9       89     0.333          0.337           0.0401  1200.
#> # ... with 2,909 more rows, and 4 more variables: cume.lift <dbl>,
#> #   mean.prediction <dbl>, min.prediction <dbl>, max.prediction <dbl>
```

Using the gains package, we are still able to keep only the topmost rows of the gain chart. If we want to share the gain chart for the top-100 rows, we might use the basic functions of dplyr, since `df2` is a tibble.

``` r
df2 %>% filter(cume.obs <= 100)
#> # A tibble: 11 x 11
#>    depth   obs cume.obs mean.resp cume.mean.resp cume.pct.of.total  lift
#>    <dbl> <int>    <int>     <dbl>          <dbl>             <dbl> <dbl>
#>  1    0.     8        8     0.500          0.500           0.00534 1800.
#>  2    0.     9       17     0.333          0.412           0.00935 1200.
#>  3    0.     9       26     0.333          0.385           0.0134  1200.
#>  4    0.     9       35     0.222          0.343           0.0160   800.
#>  5    0.     9       44     0.333          0.341           0.0200  1200.
#>  6    0.     9       53     0.444          0.358           0.0254  1600.
#>  7    0.     9       62     0.333          0.355           0.0294  1200.
#>  8    0.     9       71     0.222          0.338           0.0320   800.
#>  9    0.     9       80     0.333          0.338           0.0360  1200.
#> 10    0.     9       89     0.333          0.337           0.0401  1200.
#> 11    0.     9       98     0.222          0.327           0.0427   800.
#> # ... with 4 more variables: cume.lift <dbl>, mean.prediction <dbl>,
#> #   min.prediction <dbl>, max.prediction <dbl>
```

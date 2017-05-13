library(broom)
library(dplyr)
library(ggplot2)
library(knitr)
library(magrittr)
library(rjags)
library(rstan)
library(tidyr)
rstan_options(auto_write = TRUE)
options(mc.cores = parallel::detectCores())
opts_chunk$set(
  echo=FALSE,
  message=FALSE,
  warning=FALSE,
  fig.width=5,
  fig.height=1)

custom_boxplot <- function(df, y_label, rounding_level, co="black") {
  df                                            %>%
    use_series(y)                               %>%
    quantile(c(0.01, 0.25, 0.5, 0.75, 0.99))    -> tm
  tm                                            %>%
    round(rounding_level)                       -> lb
  df                                            %>%
    ggplot(aes(x, y))                            +
    geom_boxplot(color=co)                       +
    scale_y_continuous(breaks=tm, 
                       minor=NULL,
                       labels=lb)                +
    labs(x="", y=y_label)                        +
    coord_flip()                                %>%
    return
}

# end of file
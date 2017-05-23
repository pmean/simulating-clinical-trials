rm(list=ls())
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
  warning=FALSE)

pctl_list <- c(1, 25, 75, 99)


custom_boxplot <- function(df, y_label, rounding_level, co="black", yp=c(1, 25, 50, 75, 99)) {
  df                                            %>%
    use_series(y)                               %>%
    quantile(yp/100)                            -> tm
  tm                                            %>%
    round(rounding_level)                       -> lb
  df                                            %>%
    ggplot(aes(x, y))                            +
    geom_boxplot(color=co)                       +
    scale_y_continuous(breaks=tm,
                       minor=NULL,
                       labels=lb)                +
    theme(axis.title = element_text(color=co))   +
    theme(axis.text = element_text(color=co))    +
    theme(axis.ticks = element_line(color=co))   +
    xlab(" ")                                    +
    ylab(y_label)                                +
    coord_flip()                                %>%
    return
}

custom_boxplus <- function(df, y_label, rounding_level, co="black", yp=c(1, 25, 50, 75, 99)) {
  custom_boxplot(df, y_label, rounding_level, co=co, yp) +
  stat_summary(fun.y="mean", geom="point", size=4, color=co, pch="+")
}

custom_scatterplot <- function(df, x_name, y_name, round_x=1, round_y=0) {
  df                                              %>%
    use_series(x)                                 %>%
    quantile(pctl_list/100)                       -> x_ticks
  x_ticks                                         %>%
    round(round_x)                                -> x_labels
  df                                              %>%
    use_series(y)                                 %>%
    quantile(pctl_list/100)                       -> y_ticks
  y_ticks                                         %>%
    round(0)                                      -> y_labels
  df                                              %>%
    ggplot(aes(x, y))                              +
    xlab(x_name)                                   +
    ylab(y_name)                                   +
    scale_x_continuous(breaks=x_ticks,
                       minor_breaks=NULL,
                       labels=x_labels)            +
    scale_y_continuous(breaks=y_ticks,
                       minor_breaks=NULL,
                       labels=y_labels)            +
    geom_point()                                  %>%
    return
}

# end of file
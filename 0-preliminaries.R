# remove anything that might conflict with the current program
rm(list=ls())

# read in all the necessary libraries
library(broom)
library(dplyr)
library(ggplot2)
library(knitr)
library(magrittr)
library(rjags)
library(rstan)
library(tidyr)

# these are some recommended setting for stan
rstan_options(auto_write = TRUE)
options(mc.cores = parallel::detectCores())

# these are default settings for R Markdown 
# that hide a lot of the technical details.
opts_chunk$set(
  echo=FALSE,
  message=FALSE,
  warning=FALSE)

# these are constants used in most of the programs
N <- 350
T <- 1095
S <- 0.4
t <- 239
n <- 41

# constants for hedged prior
na <- 41
ta <- 129

# constants for delay model
S1 <- 0.2
S2 <- 0.1
S3 <- 0.2
D1 <- 0.12
D2 <- 0.4
D3 <- 0.06
t1 <- 150

t_final <- 1336
n_final <- 341
save(N, T, S, t, n, 
     na, ta, t_final, n_final,
     S1, S2, S3, D1, D2, D3, t1,
     file="fig/0.0.RData")

# more constants
n_reps <- 1000
pctl_list <- c(1, 25, 50, 75, 99)
color0 <- c(1, 0, 0) # de-emphasized color
color1 <- c(0, 1, 0) # normal color
color2 <- "green" # highlight color

l_label0 <- "Monthly accrual rate (prior)"
l_label1 <- sub("prior", "update", l_label0)

N_label0 <- "Estimated total sample size (prior)"
N_label1 <- sub("prior", "update", N_label0)
N_label2 <- sub("prior", "second update", N_label0)

N_label0a <- sub("prior", "hedged prior", N_label0)
N_label0b <- sub("prior", "simple prior", N_label0)
N_label1a <- sub("prior", "update", N_label0a)
N_label1b <- sub("prior", "update", N_label0b)
N_label1c <- sub("hedged update", "simple linear projection", N_label1a)
N_label1d <- sub("prior", "linear projection", N_label0)
N_label2a <- N_label1a
N_label2b <- N_label1b
N_label2c <- N_label1c
N_label2d <- N_label1d


# colors

co <- c(0, 1, 0)
p0 <- 0.95; q0 <- 1-p0 # controls how light the light color is
p1 <- 0.50             # controls how dark the dark color is
lt <- rgb(p0+q0*co[1], p0+q0*co[2], p0+q0*co[3])
dk <- rgb(p1*co[1], p1*co[2], p1*co[3])


# functions for boxplots and scatterplots

custom_boxplot <- function(df, y_label, rounding_level, 
                           co=c(0, 0, 1), yp=c(1, 25, 50, 75, 99)) {
  p0 <- 0.95; q0 <- 1-p0 # controls how light the light color is
  p1 <- 0.50             # controls how dark the dark color is
  lt <- rgb(p0+q0*co[1], p0+q0*co[2], p0+q0*co[3])
  dk <- rgb(p1*co[1], p1*co[2], p1*co[3])
  df                                            %>%
    use_series(y)                               %>%
    quantile(yp/100)                            -> tm
  tm                                            %>%
    round(rounding_level)                       -> lb
  df                                            %>%
    ggplot(aes(x, y))                            +
    theme(panel.background=element_rect(fill=lt)) +
    geom_boxplot(color=dk, fill=lt)                       +
    scale_y_continuous(breaks=tm,
                       minor=NULL,
                       labels=lb)                +
    theme(axis.title.x = element_text(color=dk)) +
    theme(axis.title.y = NULL)                   +
    theme(axis.text = element_text(color=dk))    +
    theme(axis.ticks = element_line(color=dk))   +
    xlab(" ")                                    +
    ylab(y_label)                                +
    coord_flip()                                %>%
    return
}

custom_boxplus <- function(df, y_label, rounding_level, 
                           co=c(0, 0, 1), yp=c(1, 25, 50, 75, 99)) {
  dk <- rgb(0.5*co[1], 0.5*co[2], 0.5*co[3])
  custom_boxplot(df, y_label, rounding_level, co=co, yp) +
  stat_summary(fun.y="mean", geom="point", size=4, color=dk, pch="+")
}

custom_scatterplot <- function(df, x_name, y_name, round_x=1, round_y=0,co="darkgreen") {
  co <- c(0, 1, 0)
  p0 <- 0.95; q0 <- 1-p0 # controls how light the light color is
  p1 <- 0.50             # controls how dark the dark color is
  lt <- rgb(p0+q0*co[1], p0+q0*co[2], p0+q0*co[3])
  dk <- rgb(p1*co[1], p1*co[2], p1*co[3])
  
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
    theme(axis.title = element_text(color=dk))     +
    theme(axis.text = element_text(color=dk))      +
    theme(axis.ticks = element_line(color=dk))     +
    theme(panel.background=element_rect(fill=lt)) +
    scale_x_continuous(breaks=x_ticks,
                       minor_breaks=NULL,
                       labels=x_labels)            +
    scale_y_continuous(breaks=y_ticks,
                       minor_breaks=NULL,
                       labels=y_labels)            +
    geom_point(col=dk)                            %>%
    return
}


# tests of gridExtra
df <- data.frame(x=rnorm(100), y=rnorm(100))
df %>% ggplot(aes(x, y)) + expand_limits(x=c(-3,3),y=c(-3,3)) +
  geom_point() +
  theme_minimal() +
  scale_x_continuous(labels=NULL) + xlab(NULL) +
  scale_y_continuous(labels=NULL) + ylab(NULL) +
  theme(axis.ticks.length=unit(0, "mm")) +
  theme(plot.margin=unit(c(0, 0, 0, 0), "mm"))    -> tst1

df %>% ggplot(aes(x)) + expand_limits(x=c(-3,3)) + geom_histogram(bins=50) +
  theme_minimal() +
  theme(plot.margin=unit(c(0, 0, 0, 0), "mm"))  +
  scale_x_continuous(labels=NULL) +
  scale_y_continuous(labels=NULL, breaks=NULL) +
  theme(axis.ticks.length=unit(0, "mm")) +
  ylab(NULL) +
  xlab(NULL) -> tst2

df %>% ggplot(aes(y)) + expand_limits(x=c(-3,3)) + geom_histogram(bins=50) +
  theme_minimal() +
  theme(plot.margin=unit(c(0, 0, 0, 0), "mm"))  +
  scale_x_continuous(labels=NULL) +
  scale_y_continuous(labels=NULL, breaks=NULL) +
  theme(axis.ticks.length=unit(0, "mm")) +
  ylab(NULL) +
  xlab(NULL) + coord_flip() -> tst3

g_pattern <- rbind(c(2,2,2,2,NA),
                   c(1,1,1,1,3),
                   c(1,1,1,1,3),
                   c(1,1,1,1,3),
                   c(1,1,1,1,3))
grid.arrange(tst1, tst2, tst3, layout_matrix=g_pattern)

df <- data.frame(x=rnorm(100), y=rnorm(100))
d1 <- density(df$x)
d2 <- density(df$y)
df %>% ggplot(aes(x, y)) + expand_limits(x=c(-3,4),y=c(-3,4)) +
  geom_point() +
  geom_polygon(data=tidy(d1), aes(x, y/max(y)+3), fill="gray") +
  geom_polygon(data=tidy(d2), aes(y/max(y)+3, x), fill="gray")

df %>% ggplot(aes(x, y)) + expand_limits(x=c(-3,5),y=c(-3, 5)) +
  geom_point() +
  geom_vline(xintercept=3.6) +
  geom_boxplot(aes(4, y)) +
  geom_polygon(data=tidy(d1), aes(x, y/max(y)+4), fill="gray")

# end of file
=
  
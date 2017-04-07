data {
  int<lower=0>           n;    // current sample size (overall)
  real<lower=0>          t;    // current time
  int<lower=0>           N;    // planned sample size
  real<lower=0>          T;    // planned time
  real<lower=0, upper=1> S;    // strength of prior
}
parameters {
  real<lower=0> lambda;        // single rate for each center
}
model {
  lambda ~ gamma(N*S, T*S);
  n ~ poisson(lambda*t);
}
generated quantities {
  real<lower=0> ntilde;
  ntilde = n + poisson_rng(lambda*(T-t));
}

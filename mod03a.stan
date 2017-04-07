data {
  int<lower=0>           J;    // number of centers
  int<lower=0>           n[J]; // current sample size in each center
  real<lower=0>          t;    // current time
  int<lower=0>           N;    // planned sample size overall
  real<lower=0>          T;    // planned time
  real<lower=0, upper=1> S;    // strength of prior
}
parameters {
  real<lower=0> lambda[J];     // single common rate for each center
  real<lower=0> alpha;         // parameters from hyperprior
  real<lower=0> beta;
}
transformed parameters {
  real<lower=0> hyper_mn;
  real<lower=0> hyper_cv;
  hyper_mn = alpha / beta;
  hyper_cv = 1/sqrt(alpha);
}
model {
  hyper_mn ~ gamma(N*S, T*S*J);
  beta ~ gamma(1, 1);
  lambda ~ gamma(alpha, beta);
  for (j in 1:J) {
    n[j] ~ poisson(lambda[j]*t);
  }
}
generated quantities {
  real<lower=0> ntilde[J];
  real<lower=0> ntilde_total;
  for (j in 1:J) {
    ntilde[j] = n[j] + poisson_rng(lambda[j]*(T-t));
  }
  ntilde_total = sum(ntilde);
}

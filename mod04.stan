data {
  int<lower=0>           J;    // number of centers
  int<lower=0>           n[J]; // current sample size in each center
  real<lower=0>          t;    // current time
  int<lower=0>           N;    // planned sample size overall
  real<lower=0>          T;    // planned time
  int<lower=0>           pseudo_n;
  real<lower=0>          pseudo_t;
  real<lower=0, upper=1> P;    // strength of prior
}
parameters {
  real<lower=0> lambda[J+1];   // single common rate for each center
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
  alpha ~ exponential(1.0);
  beta ~ gamma(0.1, 1.0);
  lambda ~ gamma(alpha, beta);
  for (j in 1:J) {
    n[j] ~ poisson(lambda[j]*t/J);
  }
  pseudo_n ~ poisson(lambda[J+1]*pseudo_t);
}
generated quantities {
  real<lower=0> ntilde[J];
  real<lower=0> ntilde_total;
  real<lower=0> average_lambda;
  average_lambda = 0;
  for (j in 1:J) {
    average_lambda = average_lambda + lambda[j]/J;
    ntilde[j] = n[j] + poisson_rng(lambda[j]*(T-t)/J);
  }
  ntilde_total = sum(ntilde);
}

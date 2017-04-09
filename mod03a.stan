data {
  int<lower=0>           J;    // number of centers
  int<lower=0>           n[J]; // current sample size in each center
  real<lower=0>          t;    // current time
  int<lower=0>           N;    // planned sample size overall
  real<lower=0>          T;    // planned time
  real<lower=0, upper=1> P;    // strength of prior
}
parameters {
  real<lower=0> lambda[J];     // separate rate for each center
  real<lower=0> hyper_mn;      // parameters from hyperprior
  real<lower=0> hyper_cv;      // parameters from hyperprior
}
transformed parameters {
  real<lower=0> alpha;
  real<lower=0> beta;
  alpha = 1 / hyper_cv^2;         // hyper_cv = 1/sqrt(alpha)
  beta = (hyper_cv^2 * hyper_mn); // hyper_mn = alpha / beta
}
model {
  hyper_mn ~ gamma(N*P, T*P);
  hyper_cv ~ gamma(1, 1);
  lambda ~ gamma(alpha, beta);
  for (j in 1:J) {
    n[j] ~ poisson(lambda[j]*t/J);
  }
}
generated quantities {
  real<lower=0> ntilde[J];
  real<lower=0> ntilde_total;
  real<lower=0> average_lambda;
  average_lambda = sum(lambda) / J;
  for (j in 1:J) {
    ntilde[j] = n[j] + poisson_rng(lambda[j]*(T-t)/J);
  }
  ntilde_total = sum(ntilde);
}

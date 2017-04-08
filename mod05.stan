data {
  int<lower=0>           J;    // number of centers
  int<lower=0>           n[J]; // current sample size in each center
  real<lower=0>          t;    // current time
  int<lower=0>           N;    // planned sample size overall
  real<lower=0>          T;    // planned time
  real<lower=0, upper=1> S;
}
transformed data {
  real<lower=0>          a;
  real<lower=0>          b;
  real<lower=0>          c;
  real<lower=0>          d;
  int<lower=0>           m;
  m = sum(n);
  a = (N/J)*t*S;
  b = t;
  c = T*S*m;
  d = m;
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
  alpha ~ gamma(a, b);
  beta ~ gamma(c, d);
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

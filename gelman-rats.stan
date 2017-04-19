data {
  int<lower=0>           J;    // number of centers
  int<lower=0>           n[J]; // sample size in each center
  int<lower=0>           x[J]; // events in each center
}
parameters {
  real<lower=0, upper=1> pi[J];         // event probability for each center
  real<lower=0> alpha;         // parameters from hyperprior
  real<lower=0> beta;          // parameters from hyperprior
}
transformed parameters {
  real<lower=0, upper=1> hyper_mn;
  real<lower=0>          hyper_tau;
  hyper_mn = alpha / (alpha+beta);
  hyper_tau= alpha+beta;
}
model {
  alpha ~ gamma(0.001, 0.001);
  beta  ~ gamma(0.001, 0.001);
  for (j in 1:J) {
    pi[j] ~ beta(alpha, beta);
    x[j] ~ binomial(n[j], pi[j]);
  }
}

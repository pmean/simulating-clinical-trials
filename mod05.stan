data {
  int<lower=0>           J;    // number of centers
  int<lower=0>           n[J]; // current sample size in each center
  real<lower=0>          t;    // current time
  int<lower=0>           N;    // planned sample size overall
  real<lower=0>          T;    // planned time
  real<lower=0, upper=1> P;    // strength of prior
}
parameters {
  real<lower=0> lambda;        // overall rate for each center
  real<lower=0> eta[J];        // deviation from overall rate
  real<lower=0> alpha;         // parameter from deviation distribution
}
transformed parameters {
  real<lower=0> deviation_cv;
  deviation_cv = 1/sqrt(alpha);
} 
model {
  alpha ~ exponential(1.0);
  lambda ~ gamma(N*P, T*P);
  for (j in 1:J) {
    eta[J] ~ gamma(alpha, alpha); 
    n[j] ~ poisson(eta[j]*lambda*t/J);
  }
}
generated quantities {
  real<lower=0> ntilde[J];
  real<lower=0> ntilde_total;
  real<lower=0> average_lambda;
  average_lambda = lambda*sum(eta) / J;
  for (j in 1:J) {
    ntilde[j] = n[j] + poisson_rng(eta[j]*lambda*(T-t)/J);
  }
  ntilde_total = sum(ntilde);
}

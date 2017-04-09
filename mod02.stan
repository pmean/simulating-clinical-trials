data {
  int<lower=0>           J;    // number of centers
  int<lower=0>           n[J]; // current sample size in each center
  real<lower=0>          t;    // current time
  int<lower=0>           N;    // planned sample size overall
  real<lower=0>          T;    // planned time
  real<lower=0, upper=1> P;    // strength of prior
}
parameters {
  real<lower=0> lambda;        // single common rate for each center
}
model {
  lambda ~ gamma(N*P, T*P);
  // gamma(N*P/J, T*P) also works but it weakens the prior.
  for (j in 1:J) {
    n[j] ~ poisson(lambda*t/J);
  }
}
generated quantities {
  real<lower=0> ntilde[J];
  real<lower=0> ntilde_total;
  for (j in 1:J) {
    ntilde[j] = n[j] + poisson_rng(lambda*(T-t)/J);
  }
  ntilde_total = sum(ntilde);
}

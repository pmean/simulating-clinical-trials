data {
  int<lower=0>           n;    // current sample size (overall)
  int<lower=0>           J;    // number of centers
  int<lower=0>           x[J]; // current sample size (individual centers A-D)
  real<lower=0>          t;    // current time
  int<lower=0>           N;    // planned sample size
  real<lower=0>          T;    // planned time
  real<lower=0, upper=1> S;    // strength of prior
}
parameters {
  real<lower=0> lambda;        // single rate for each center
}
model {
  lambda ~ gamma(N*S, T*S*M);
  // you could use gamma((N/M)*S, T*S)
  // but that would dilute the strength
  // of the informative prior distribution
  for (j in 1:J) {
    x ~ poisson(t*lambda);
  }
}
generated quantities {
  real<lower=0> xstar[J];
  xstar = sum(x) + poisson_rng(lambda*(T-t));
}

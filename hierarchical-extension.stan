data {
  int<lower=1>           N; // planned number of patients total
  int<lower=0>           M; // number of centers
  real<lower=0>          T; // planned duration of trial
  real<lower=0, upper=1> S; // strength of prior for lambda
  real<lower=0, upper=1> S1; // strength of prior for sigma_sq
  real<lower=0>          GSD; // geometric standard deviation of center effect
  int<lower=0>           n[M]; // observed number of patients at each center
  real<lower=0>          t;    // observed time--t=0 implies prior to start
}
parameters {
  real<lower=0> lambda; // overall rate
  real<lower=0> eta[M]; // multiplier for center effect
  real<lower=0> sigma_sq; // between center variation
}
model {
  lambda ~ gamma(N*S, T*S);
  eta ~ lognormal(0, sigma_sq);
  sigma_sq ~ gamma(N*S1, N*S1/log(GSD));
  if (t>0) {
    for (i in 1:M) {
      n[i] ~ poisson(lambda*eta[i]*t/M);
    }
  }
}
generated quantities {
  int<lower=0> Nstar;
  int<lower=0> Mstar[M];
  for (i in 1:M) {
    Mstar[i] = n[i] + poisson_rng(lambda*eta[i]*(T-t)/M);
  }
  Nstar = sum(Mstar);
}

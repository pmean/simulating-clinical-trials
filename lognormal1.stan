data {
  int<lower=1>           N; // planned number of patients total
  real<lower=0>          T; // planned duration of trial
  real<lower=0, upper=1> S; // strength of prior for lambda
  real<lower=0>          GSD; // geometric standard deviation of center effect
  int<lower=1>           M; //number of centers
}
parameters {
  real<lower=0> lambda; // overall rate
  real<lower=0> eta[M]; // center effect
}
model {
  lambda ~ gamma(N*S, T*S);
  eta ~ lognormal(0, log(GSD));
}
generated quantities {
  real <lower=0, upper=100> max_pct;
  real<lower=0> Mstar[M];
  real<lower=0> Nstar;
  for (i in 1:M) {
    Mstar[i] = poisson_rng(T*lambda*eta[i]/M);
  }
  Nstar = sum(Mstar);
  max_pct = 100*max(Mstar) / Nstar;
}


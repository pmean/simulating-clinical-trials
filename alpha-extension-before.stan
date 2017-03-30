data {
  int<lower=1>           N; // planned number of patients 
  real<lower=0>          T; // planned duration of trial
  real<lower=0, upper=1> S; // strength of prior
}
parameters {
  real<lower=0> lambda;
  real<lower=0, upper=T/4> alpha;
}
model {
  lambda ~ gamma(N*S, T*S);
  alpha ~ uniform(0, T/4);
}
generated quantities {
  real<lower=0> Nstar;
  Nstar = poisson_rng(lambda*(T-alpha));
}

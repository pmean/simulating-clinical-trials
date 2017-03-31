data {
  int<lower=1>           N; // planned number of patients 
  real<lower=0>          T; // planned duration of trial
  real<lower=0, upper=1> S; // strength of prior
}
parameters {
  real<lower=0> lambda;
  real<lower=1/(N*S), upper=1> pi;
}
model {
  pi ~ uniform(1/(N*S), 1)
  lambda ~ gamma(pi*N*S, pi*T*S);
}
generated quantities {
  real<lower=0> Nstar;
  Nstar = poisson_rng(lambda*T);
}

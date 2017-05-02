data {
  int<lower=1>           N; // planned number of patients 
  real<lower=0>          T; // planned duration of trial
  real<lower=0, upper=1> S; // strength of prior
  int<lower=0>           n; // observed patients
  real<lower=0>          t; // observed time
}
parameters {
  real<lower=0> lambda;
  real<lower=1/(N*S), upper=2> pi; // hedging hyperprior
}
model {
  pi ~ uniform(0, 2);
  lambda ~ gamma(1+pi*(N*S-1), T/N+pi*(T*S-T/N));
  if (t>0) n ~ poisson(t*lambda);
}
generated quantities {
  real<lower=0> Nstar;
  Nstar = n + poisson_rng((T-t)*lambda);
}

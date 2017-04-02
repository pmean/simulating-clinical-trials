data {
  int<lower=1>           N; // planned number of patients 
  real<lower=0>          T; // planned duration of trial
  real<lower=0, upper=1> S; // strength of prior
  int<lower=0>           n; // observed patients
  real<lower=0>          t; // observed time
}
parameters {
  real<lower=0> lambda;
  real<lower=1/(N*S), upper=1> pi; // hedging hyperprior
}
model {
  pi ~ uniform(1/(N*S), 1);
  lambda ~ gamma(pi*N*S, pi*T*S);
  n ~ poisson(t*lambda);
}
generated quantities {
  real<lower=0> Nstar;
  Nstar = n + poisson_rng((T-t)*lambda);
}

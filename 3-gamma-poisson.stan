data {
  int<lower=1>           N; // planned number of patients 
  int<lower=0>           n; // observed patients
  real<lower=0, upper=1> S; // strength of prior
  real<lower=0>          T; // planned duration of trial
  real<lower=0>          t; // observed time
}
parameters {
  real<lower=0> lambda;
}
model {
  lambda ~ gamma(N*S, T*S);
  if (t>0) n ~ poisson(t*lambda);
}
generated quantities {
  real<lower=0> Nstar;
  Nstar = n + poisson_rng((T-t)*lambda);
}

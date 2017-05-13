data {
  int<lower=1>           N; // planned number of patients
  int<lower=0>          T; // planned duration of trial
  real<lower=0, upper=1> S; // strength of prior
  int<lower=0>           t; // observed time
  int<lower=0>           n[t]; // observed counts
}
parameters {
  real<lower=0> lambda;
}
model {
  lambda ~ gamma(N*S, T*S);
  n ~ poisson(lambda);
}
generated quantities {
  real<lower=0> Nstar[T];
  Nstar[1] = n[1];
  for (i in 2:t) {
    Nstar[i] = Nstar[i-1] + n[i];
  }
  for (i in (t+1):T) {
    Nstar[i] = Nstar[i-1] + poisson_rng(lambda);
  }
}

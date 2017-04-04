data {
  int<lower=1>           N; // planned number of patients total
  int<lower=0>           M; // number of centers
  real<lower=0>          T; // planned duration of trial
  real<lower=0, upper=1> S; // strength of prior
}
parameters {
  real<lower=0> lambda;
  real<lower=0.1, upper=0.5> sigma;
  real eta[M];
}
model {
  sigma ~ uniform(0.1, 0.5);
  eta ~ normal(0, sigma);
  lambda ~ gamma(N*S, T*S);
}
generated quantities {
  real<lower=0> Nstar;
  Nstar = poisson_rng(sum(exp(eta))*(lambda/M)*T);
}

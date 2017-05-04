data {
  int<lower=1>           N; // planned number of patients total
  real<lower=0>          T; // planned duration of trial
  real<lower=0, upper=1> S; // strength of prior for lambda
  real<lower=0, upper=1> S1; // strength of prior for sigma_sq
  real<lower=0>          GSD; // geometric standard deviation of center effect
  int<lower=1>          M; //number of centers
}
parameters {
  real<lower=0> lambda; // overall rate
  real<lower=0> sigma; // between center variation
  real<lower=0> eta[M]; // center effect
}
model {
  lambda ~ gamma(N*S, T*S);
  eta ~ lognormal(-0.5*sigma^2, sigma);
  sigma ~ gamma(N*S1, N*S1/log(GSD));
}
generated quantities {
  real<lower=0> Nstar;
  Nstar = poisson_rng(T*lambda*sum(eta)/M);
}


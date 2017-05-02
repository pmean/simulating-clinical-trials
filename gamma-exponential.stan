data {
  int<lower=1>           N; // planned number of patients 
  real<lower=0>          T; // planned duration of trial
  real<lower=0, upper=1> S; // strength of prior
  int<lower=0>           n; // observed patients
  real<lower=0>          t; // observed time
}
parameters {
  real<lower=0> beta;
}
transformed parameters {
  real<lower=0> lambda; 
  lambda = 1/beta;
}
model {
  beta ~ gamma(N*S, T*S);
  if (t>0) t ~ gamma(n, beta);
}
generated quantities {
  real<lower=0> Tstar;
  Tstar = (t + gamma_rng(N-n, beta)) / 365;
}

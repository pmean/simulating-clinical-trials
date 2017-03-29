data {
  int<lower=1>           N; // planned number of patients 
  real<lower=0>          T; // planned duration of trial
  real<lower=0, upper=1> S; // strength of prior
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
}
generated quantities {
  real<lower=0> Tstar;
  Tstar = gamma_rng(N, beta) / 365;
}

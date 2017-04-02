data {
  real<lower=0>          T;  // planned duration of trial
  real<lower=0, upper=T> D;  // planned delay associated with IRB approval
  int <lower=0>          N;  // planned number of patients prior to losses
  int <lower=0, upper=N> E;  // planned losses due to exclusions
  int <lower=0, upper=X> R;  // planned losses due to refusals.
  real<lower=0, upper=1> SD; // strength of prior for D
  real<lower=0, upper=1> SN; // strength of prior for N
  real<lower=0, upper=1> SE; // strength of prior for E
  real<lower=0, upper=1> SR; // strength of prior for R
}
parameters {
  real<lower=0> lambda;
  real<lower=0> delta;
  real<lower=0, upper=1> pi;
}
model {
  lambda ~ gamma(N0*S0, T*S0);
  pi     ~ beta(N1*S1, (N0-N1)*S1)
}
generated quantities {
  real<lower=0> Nstar;
  N0star = poisson_rng(lambda*T);
  N1star = binomial_rng(N0star, pi)
}

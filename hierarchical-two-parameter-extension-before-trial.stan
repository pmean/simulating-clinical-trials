data {
  int<lower=1>           N; // planned number of patients total
  int<lower=0>           M; // number of centers
  real<lower=0>          T; // planned duration of trial
  real<lower=0, upper=1> S; // strength of prior
  real<lower=0>          B[M]; // number of beds
}
transformed data {
  real<lower=0> total_beds; 
  total_beds = sum(B);
}
parameters {
  real<lower=0> lambda[M];  // rate for individual centers
  real<lower=0> mu;         // hyperprior for overal rate
  real<lower=0> scale;      // hyperprior for between center variation
}
transformed parameters {
  real<lower=0> alpha;
  real<lower=0> beta;
  alpha = scale;
  beta = scale / mu;
}
model {
  mu ~ gamma(N*S, T*S*total_beds);
  scale ~ gamma(100, 100);
  lambda ~ gamma(alpha, beta);
}
generated quantities {
  real<lower=0> Nstar;
  real<lower=0> Mstar[M];
  for (I in 1:M) {
    Mstar[I] = poisson_rng(lambda[I]*T*B[I]);
  }
  Nstar = sum(Mstar);
}

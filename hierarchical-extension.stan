data {
  int<lower=1>           N; // planned number of patients total
  real<lower=0>          T; // planned duration of trial
  real<lower=0, upper=1> S; // strength of prior for lambda
  real<lower=0, upper=1> S1; // strength of prior for sigma
  real<lower=0>          GSD; // geometric standard deviation of center effect
  int<lower=1>           M; //number of centers
}
parameters {
  real<lower=0> lambda; // overall rate
  real<lower=0> sigma_sq; // between center variation
  real<lower=0> eta[M]; // center effect
}
transformed parameters {
  real<lower=0> sigma;
  real<lower=1> gsd;
  sigma = sqrt(sigma_sq);
  gsd = exp(sigma);
}
model {
  lambda ~ gamma(N*S, T*S);
  eta ~ lognormal(-0.5*sigma^2, sigma);
  sigma_sq ~ inv_gamma(N*S1, N*S1*log(GSD)^2);
}
generated quantities {
  real <lower=0, upper=100> max_pct;
  real<lower=0> Mstar[M];
  real<lower=0> Nstar;
  for (i in 1:M) {
    Mstar[i] = poisson_rng(T*lambda*eta[i]/M);
  }
  Nstar = sum(Mstar);
  max_pct = 100*max(Mstar) / Nstar;
}


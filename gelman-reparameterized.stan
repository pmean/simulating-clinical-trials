data {
  int<lower=0>           J;     // number of centers
  int<lower=0>           n[J];  // sample size in each center
  int<lower=0>           x[J];  // events in each center
}
parameters {
  real<lower=0, upper=1> pi[J]; // event probability for each center
  real<lower=0> hyper_mn;
  real<lower=0> hyper_tau;
}
transformed parameters {
  real<lower=0> alpha;  
  real<lower=0> beta;   
  alpha =    hyper_mn  * hyper_tau;
  beta =  (1-hyper_mn) * hyper_tau;
}
model {
  hyper_mn ~ beta(1, 1);
  hyper_tau ~ gamma(2, 1);
  for (j in 1:J) {
    pi[j] ~ beta(alpha, beta);
    x[j] ~ binomial(n[j], pi[j]);
  }
}

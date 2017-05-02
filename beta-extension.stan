data {
  int<lower=1>           N;    // planned number of patients 
  real<lower=0>          T;    // planned duration of trial
  real<lower=0, upper=1> S;    // strength of prior for accrual rate
  real<lower=0, upper=1> S1;   // strength of prior for delta1
  real<lower=0, upper=1> D1;   // prior mean for delta1
  real<lower=0, upper=1> S2;   // strength of prior for delta2
  real<lower=0, upper=1> D2;   // prior mean for delta2
  real<lower=0, upper=1> S3;   // strength of prior for delta3
  real<lower=0, upper=1> D3;   // prior mean for delta3
  int<lower=0>           t;    // observed time
  int<lower=0>           n[t]; // observed patients
  int<lower=0>           c[t]; // cumulative patients
}
parameters {
  real<lower=0> lambda;
  real<lower=0, upper=1> delta1;
  real<lower=0, upper=1> delta2;
  real<lower=0, upper=1> delta3;
}
model {
  lambda ~ gamma(N*S, T*S);
  delta1 ~ beta(N*S1*D1, N*S1*(1-D1));
  delta2 ~ beta(N*S2*D2, N*S2*(1-D2));
  delta3 ~ beta(N*S3*D3, N*S3*(1-D3));
  T3 = floor(delta3*T)
  for (i in 1:T3) {
    n[i] ~ poisson(delta2*lambda);
  }
  for (i in (T3+1):t) {
    n[i] ~ poisson(lambda);
  }
}
generated quantities {
  real<lower=0> Nstar;
  real<lower=0, upper=1> efficiency;
  efficiency = (1-delta1-delta2*delta3);
  Nstar = poisson_rng(lambda*(T*efficiency));
}

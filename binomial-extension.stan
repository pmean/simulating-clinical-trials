data {
  int<lower=1>           N; // planned number of patients 
  real<lower=0>          T; // planned duration of trial
  real<lower=0, upper=1> S; // strength of prior
  int<lower=0>           n1; // observed patients
  int<lower=0>           n2; // after exclusions
  int<lower=0>           n3; // after exclusions and refusals
  real<lower=0>          t; // observed time
  real<lower=0, upper=1> P1; // planned proportion after exclusions
  real<lower=0, upper=1> S1; // strength of prior for exclusion proportion
  real<lower=0, upper=1> P2; // planned proportion after refusals
  real<lower=0, upper=1> S2; // strength of prior for refusal proportion

}
parameters {
  real<lower=0> lambda;
  real<lower=0, upper=1> pi1;
  real<lower=0, upper=1> pi2;
}
model {
  lambda ~ gamma(N*S, T*S);
  pi1 ~ beta(N*S1*P1, N*S1*(1-P1));
  pi2 ~ beta(N*S2*P2, N*S2*(1-P2));
  if (t>0) {
    n1 ~ poisson(t*lambda);
    n2 ~ binomial(n1, pi1);
    n3 ~ binomial(n2, pi2);
  }
}
generated quantities {
  int<lower=0> N1star;
  int<lower=0> N2star;
  int<lower=0> N3star;
  N1star = n1 + poisson_rng((T-t)*lambda);
  N2star = n2 + binomial_rng(N1star-n1, pi1);
  N3star = n3 + binomial_rng(N2star-n2, pi2);
}

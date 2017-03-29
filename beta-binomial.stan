data {
  int<lower=1> n; // number of trials 
  int<lower=0, upper=n> x; // number of successes
}
parameters {
  real<lower=0, upper=1> pi; 
}
model {
  x ~ binomial(n, pi);
  pi ~ beta(4, 16);
}

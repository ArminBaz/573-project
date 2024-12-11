// Base model
data {
  int<lower=0> N;        // number of seasons
  array[N] int<lower=0> AB;    // at bats per season
  array[N] int<lower=0> H;     // hits per season
  array[N] int<lower=0> Year;  // career year
}
parameters {
  real<lower=0,upper=1> theta_base;    // base batting average
  real learning_rate;                   // yearly improvement/decline rate
}
model {
  vector[N] theta;  // year-specific batting average
  
  // Priors
  theta_base ~ beta(80, 240);      // centers around .250 batting average
  learning_rate ~ normal(0, 0.02); // allows for yearly changes
  
  // Calculate year-specific batting average
  for (i in 1:N) {
    theta[i] = theta_base + learning_rate * (Year[i] - 1);
  }
  
  // Likelihood
  for (i in 1:N) {
    H[i] ~ binomial(AB[i], theta[i]);
  }
}
generated quantities {
  vector[N] predicted_ba;
  vector[N] log_lik;  // Added for LOOIC
  vector[N] theta;    // Added to calculate log_lik
  
  // Calculate year-specific batting average
  for (i in 1:N) {
    theta[i] = theta_base + learning_rate * (Year[i] - 1);
    predicted_ba[i] = theta[i];
    // Calculate log likelihood for each observation
    log_lik[i] = binomial_lpmf(H[i] | AB[i], theta[i]);
  }
}
data {
  int<lower=0> N;        // number of seasons
  array[N] int<lower=0> AB;    // at bats per season
  array[N] int<lower=0> H;     // hits per season
  array[N] int<lower=0> Year;  // career year
}

parameters {
  real<lower=0,upper=1> theta_base;    // base batting average
  real learning_rate;                   // yearly improvement/decline rate
  real<lower=0,upper=1> rho;           // autocorrelation parameter
  vector[N] eps;                       // random effects for AR process
}

transformed parameters {
  vector<lower=0,upper=1>[N] theta;  // year-specific batting average
  
  // First year
  theta[1] = inv_logit(logit(0.25) + eps[1]);
  
  // Subsequent years with AR(1) process
  for (i in 2:N) {
    real mu = logit(theta_base) + learning_rate * (Year[i] - 1);
    theta[i] = inv_logit(mu + rho * eps[i-1] + eps[i]);
  }
}

model {
  // Priors
  theta_base ~ beta(80, 240);      // centers around .250 batting average
  learning_rate ~ normal(0, 0.02); // allows for yearly changes
  rho ~ beta(2, 2);               // moderate autocorrelation
  eps ~ normal(0, 0.1);           // random effects
  
  // Likelihood
  for (i in 1:N) {
    H[i] ~ binomial(AB[i], theta[i]);
  }
}

generated quantities {
  vector[N] predicted_ba;
  
  // Generate predictions
  predicted_ba[1] = inv_logit(logit(0.25) + eps[1]);
  
  for (i in 2:N) {
    real mu = logit(theta_base) + learning_rate * (Year[i] - 1);
    predicted_ba[i] = inv_logit(mu + rho * eps[i-1] + eps[i]);
  }
}
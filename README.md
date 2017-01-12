### Introduction to Intelligent Computing
# Final Project - 火の人工知能玄

Implement a forest fire risk assessment system to model the unknown burned area using the BBN (Bayesian belief networks).

## Research Steps

1. Collect the statistics and data within the target region.

2. Identify the causal state variables in the target problem domain to form a belief network with their causality links.

3. Establish CPT by assigning the subjective/objective probability entries on CPT for each link.

4. Implement the MCMC algorithm and simulate the conditional Bayesian probability inference by sampling given evidence input as facts known in the domain.

5. Validate the BBN to see how accurate the assessment hypothesis with respect to various evidence conditions observed.

## Build Environment
- Windows x64
- MATLAB R2016a
- [Bayes Net Toolbox](http://bayesnet.github.io/bnt/docs/usage.html)
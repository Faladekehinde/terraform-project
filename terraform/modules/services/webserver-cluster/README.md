## Chapter 6 Learnings In your own words:
Does sensitive = true prevent secrets from being stored in state? What does it actually do?
NO, It prevents the secret from being displayed on the terminal output

## What is the difference between HashiCorp Vault and AWS Secrets Manager and when would you use each?

# Hashicorp Vailut: 
 * Use with multiple clouds (AWS, Azure, GCP)
 * When advanced security control is needed
 * For dynamic secrets

# AWS Secrets Manager:
 * Used when working only in AWS platforms
 * You don’t want to manage infrastructure

## Why can you not fully prevent secrets from appearing in state for some resource types?

* I can not fully prevent secrets from appearing in state for some resources because Terraform must store the actual value to track infrastructure state, detect changes, and some resources require those secrets to function. That is why S3 Backend configuration comes into play, and other less privileged access.

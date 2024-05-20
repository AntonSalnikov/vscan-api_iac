AWS profiles in your ~/.aws/credentials should have the next names:
"vscan-api-test" for Test environment
"vscan-api-prod" for Prod environment


Example for multi-env terraforming:

terraform workspace new test


terraform workspace list
terraform workspace select test
terraform init -backend-config=config/test-backend.conf
terraform plan

````
terraform init && terraform plan && terraform apply --auto-approve
terraform output -json | jq 'with_entries(.value |= .value)' > ../../app/values.json
````

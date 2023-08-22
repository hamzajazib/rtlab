# Deployment script

Set-Location $pwd\Terraform

#Create execution plan to destroy all resources and output to .tfplan file
terraform plan -destroy -out main.destroy.tfplan; terraform apply main.destroy.tfplan

#Apply execution plan using .tfplan file
terraform apply main.destroy.tfplan
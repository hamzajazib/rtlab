terraform {
	required_version = ">=1.5"
	required_providers {
		azapi = {
			source  = "azure/azapi"
			version = "1.8.0"
		}
		azurerm = {
			source  = "hashicorp/azurerm"
			version = "3.70.0"
		}
		random = {
			source  = "hashicorp/random"
			version = "3.5.1"
		}
	}
}

provider "azurerm" {
	features {}

	subscription_id   = "<SUBSCRIPTIONID>"
	tenant_id         = "<TENANTID>"
	client_id         = "<CLIENTID>"
	client_secret     = "<CLIENTSECRET>"
}
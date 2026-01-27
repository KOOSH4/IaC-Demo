// main.bicep
// This is the main entry point for the deployment.
// Deploy using: az deployment sub create --location swedencentral --template-file main.bicep --parameters githubRepo='owner/repo' storageAccountName='yourstorageaccount'

targetScope = 'subscription'

// --- Parameters ---
// These are the values you might want to change for different deployments.

// The Azure region for all resources.
param location string = 'swedencentral'

// The name of the Resource Group to create for the backend resources.
param resourceGroupName string = 'rg-tf-backend'

// Your GitHub repository in the format 'owner/repository'.
@description('GitHub repository in the format owner/repository')
param githubRepo string

// The storage account name (must be globally unique, 3-24 chars, lowercase alphanumeric)
@description('Storage account name for Terraform state (globally unique)')
@minLength(3)
@maxLength(24)
param storageAccountName string

// --- Variables ---

var storageContainerName = 'tfstate'
var managedIdentityName = 'id-iac-wss-sec-1'

// --- Resources ---

// Create the Resource Group
resource rg 'Microsoft.Resources/resourceGroups@2021-04-01' = {
  name: resourceGroupName
  location: location
}

// --- Modules ---
// Calling the modular Bicep files to create the resources.

// Module to deploy the Managed Identity and Federated Credential for GitHub Actions
module managedIdentity 'modules/mi.bicep' = {
  scope: rg
  name: 'managedIdentityDeployment'
  params: {
    location: location
    managedIdentityName: managedIdentityName
    githubRepo: githubRepo
  }
}

// Module to deploy the Storage Account for Terraform state
module storageAccount 'modules/st.bicep' = {
  scope: rg
  name: 'storageAccountDeployment'
  params: {
    location: location
    storageAccountName: storageAccountName
    storageContainerName: storageContainerName
  }
}

// --- Role Assignments ---

// Contributor role definition ID (built-in role)
var contributorRoleId = 'b24988ac-6180-42a0-ab88-20f7382dd24c'
// User Access Administrator role definition ID (built-in role)
var userAccessAdminRoleId = '18d7d88d-d35e-4fb5-a5c3-7773c20a72d9'

// Assign Contributor role to the Managed Identity at Subscription scope
resource contributorRoleAssignment 'Microsoft.Authorization/roleAssignments@2022-04-01' = {
  name: guid(subscription().id, managedIdentityName, contributorRoleId)
  properties: {
    roleDefinitionId: subscriptionResourceId('Microsoft.Authorization/roleDefinitions', contributorRoleId)
    principalId: managedIdentity.outputs.principalId
    principalType: 'ServicePrincipal'
    description: 'Allows the managed identity to manage resources in the subscription'
  }
}

// Assign User Access Administrator role to the Managed Identity at Subscription scope
resource userAccessAdminRoleAssignment 'Microsoft.Authorization/roleAssignments@2022-04-01' = {
  name: guid(subscription().id, managedIdentityName, userAccessAdminRoleId)
  properties: {
    roleDefinitionId: subscriptionResourceId('Microsoft.Authorization/roleDefinitions', userAccessAdminRoleId)
    principalId: managedIdentity.outputs.principalId
    principalType: 'ServicePrincipal'
    description: 'Allows the managed identity to assign roles'
  }
}

// --- Outputs ---
// These are the important values you'll need after deployment.

output resourceGroupName string = rg.name
output managedIdentityName string = managedIdentity.outputs.name
output managedIdentityPrincipalId string = managedIdentity.outputs.principalId
output managedIdentityClientId string = managedIdentity.outputs.clientId
output managedIdentityResourceId string = managedIdentity.outputs.resourceId

output storageAccountName string = storageAccount.outputs.name
output storageContainerName string = storageAccount.outputs.containerName

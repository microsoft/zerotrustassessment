# 011: Identity

## Overview

When you enable and use a managed identity (formerly Managed Service Identity or MSI) for authentication, your logic apps can more easily access Azure resources that are protected by Azure Active Directory (Azure AD). A managed identity removes the need for you to manage credentials or Azure AD tokens by providing Azure services with an identity that is managed by Azure AD.

## Zero Trust Pillars

* Least Privileged Access
* Assume breach

## What to do

* Use system assigned whenever possible to avoid accidental access
* A system assigned managed identity is restricted to one per resource and is tied to the lifecycle of this resource without storing credentials in code
* User assigned managed identities enable Azure resources to authenticate to cloud services (e.g. Azure Key Vault) without storing credentials in code.  Can be shared across multiple resources
* Grant either one the minimal level of permissions required.

## Why set this?

You always want to authenticate the user or accounts accessing your logic app.  By using managed identity, you will get the highest level of security in regards to authenticaiton.

## Reference

* [Azure Logic Apps - Authenticate with managed identity for Azure AD OAuth-based connectors](https://techcommunity.microsoft.com/t5/azure-integration-services-blog/azure-logic-apps-authenticate-with-managed-identity-for-azure-ad/ba-p/2066254)
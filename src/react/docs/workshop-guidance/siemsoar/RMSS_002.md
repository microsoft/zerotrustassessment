# 002: Microsoft Entra

## Overview

You can use Microsoft Sentinel's built-in connector to collect data from Microsoft Entra ID and stream it into Microsoft Sentinel. The connector allows you to stream the following log types:

- Sign-in logs, which contain information about interactive user sign-ins where a user provides an authentication factor.

The Microsoft Entra connector now includes the following three additional categories of sign-in logs, all currently in PREVIEW:

     Non-interactive user sign-in logs, which contain information about sign-ins performed by a client on behalf of a user without any interaction or authentication factor from the user.

     Service principal sign-in logs, which contain information about sign-ins by apps and service principals that don't involve any user. In these sign-ins, the app or service provides a credential on its own behalf to authenticate or access resources.

     Managed Identity sign-in logs, which contain information about sign-ins by Azure resources that have secrets managed by Azure. For more information, see What are managed identities for Azure resources?

- Audit logs, which contain information about system activity relating to user and group management, managed applications, and directory activities.

- Provisioning logs (also in PREVIEW), which contain system activity information about users, groups, and roles provisioned by the Microsoft Entra provisioning service.

- Microsoft Graph activity logs, which contain information about HTTP requests accessing your tenant’s resources through the Microsoft Graph API.

## Reference

* [Connect Microsoft Entra data to Microsoft Sentinel](hhttps://learn.microsoft.com/en-us/azure/sentinel/connect-azure-active-directory)
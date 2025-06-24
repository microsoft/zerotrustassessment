# Roles and permissions in Microsoft Sentinel

**Implementation Effort:** Low: Customer IT and Security Operations teams need to drive projects to set up and manage Azure RBAC roles within Microsoft Sentinel.

**User Impact:** Low: A subset of non-privileged users, such as security analysts and responders, need to take action or be notified of changes.

## Overview
Planning roles and permissions in Microsoft Sentinel involves using Azure Role-Based Access Control (RBAC) to assign appropriate access levels to users, groups, and services. Sentinel provides built-in roles such as **Reader**, **Responder**, **Contributor**, **Playbook Operator**, and **Automation Contributor**, each with specific capabilities. For example, a Sentinel Contributor can create and edit analytics rules, while a Responder can manage incidents. These roles can be assigned at the workspace, resource group, or subscription level, depending on the scope of access required.

Proper role planning ensures that users only have the permissions necessary to perform their tasks, aligning with the **Zero Trust principle of Least Privilege Access**. Failing to implement this correctly can lead to over-permissioned accounts, increasing the risk of accidental or malicious misuse of sensitive security data and controls.


## Reference
[Roles and permissions in Microsoft Sentinel](https://learn.microsoft.com/en-us/azure/sentinel/roles)

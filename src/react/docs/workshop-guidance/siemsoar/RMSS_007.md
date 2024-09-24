# 007: Access Control

## Overview

Azure role-based access control (Azure RBAC) is the authorization system you use to manage access to Azure resources. To grant access, you assign roles to users, groups, service principals, or managed identities at a particular scope.

## Zero Trust Pillars

* Least Privileged Access

## What to do

* Verify that only those accounts that need access to the workflow have access.
* Use the roles listed previously to ensure proper rights
* Periodically check to see if access is still needed

## Why set this?

By reducing the number of accounts that have access to the logic app, you reduce the target area for bad actors to attack.  By eliminating excess rights, if an account is compromised, the area of effect will be reduced.

## Reference

* [Assign Azure roles using the Azure portal](https://learn.microsoft.com/en-us/azure/role-based-access-control/role-assignments-portal)
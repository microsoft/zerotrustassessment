# 017: Certificates

## Overview

Certificates are used to confirm the authentication, and identity of a system.  Their use was very prevelent but have been replaces with managed identies

## Zero Trust Pillars

* Assume breach
* Verify Explicitely

## What to do

* Avoid use when possible.  Use Managed Identities instead
* Use to secure B2B messages
* If not Azure managed, develop workflow to renew certificates as needed.

## Why set this?

While certificates were very good security when they came out, best practice now is to use managed identity to access everything to allow for fine tuned access and to avoid having to manage all the certificates.

## Reference

* [Add certificates to integration accounts for securing messages in workflows with Azure Logic Apps](https://learn.microsoft.com/en-us/azure/logic-apps/logic-apps-enterprise-integration-certificates)
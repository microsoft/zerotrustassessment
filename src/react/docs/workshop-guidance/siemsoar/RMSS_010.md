# 010: Access Keys

## Overview

Generate the Logic App’s SAS URLs using the selected access key.  Used with workflows that utilize the HTTP request trigger.  Go into the individual workflow in Standard Logic Apps to see this.

## Zero Trust Pillars

* Assume breach

## What to do

* Minimize use
* Regenerate often if being used

## Why set this?

Using access keys will limit which systems can access your system, making it harder for bad actors to gain unauthorized acess.  While this is good security, there are newer features of logic apps, like managed identities, that provide better security so the use of Access Keys should be minimized.

## Reference

* [Secure access and data for workflows in Azure Logic Apps](https://learn.microsoft.com/en-us/azure/logic-apps/logic-apps-securing-a-logic-app?tabs=azure-portal#regenerate-access-keys)
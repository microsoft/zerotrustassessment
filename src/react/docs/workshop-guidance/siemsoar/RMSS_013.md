# 013: Workflow Settings

## Overview

Set items including, which IP addresses can trigger the workflow and which integration account to use with B2B workflows.

## Zero Trust Pillars

* Least Privileged Access
* Assume breach
* Verify Explicitely

## What to do

* Limit which IP Address(es) can trigger the workflow or only allow other Logic Apps to trigger this one when possible.
* Validate that the integration account ([Create and manage integration accounts | Microsoft Learn](https://learn.microsoft.com/en-us/azure/logic-apps/enterprise-integration/create-integration-account?tabs=azure-portal%2Cconsumption)) (used with Enterprise Integration pack)

## Why set this?

By limiting access to your logic app from 3rd parties, you minimize the attack area.

## Reference

* [Limits and configuration reference for Azure Logic Apps](https://learn.microsoft.com/en-us/azure/logic-apps/logic-apps-limits-and-config?tabs=consumption)
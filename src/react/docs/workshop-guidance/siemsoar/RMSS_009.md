# 009: Authorization

## Overview

In a Consumption logic app workflow that starts with a request-based trigger, you can authenticate inbound calls sent to the endpoint created by that trigger by enabling [Microsoft Entra ID OAuth](https://learn.microsoft.com/en-us/azure/active-directory/develop/).

## Zero Trust Pillars

* Least Privileged Access
* Assume breach
* Verify Explicitely

## What to do

* Define which claims can be used to call the Logic App
* Note: An inbound call to the request endpoint can use only one authorization scheme, either OAuth with Microsoft Entra ID or [Shared Access Signature (SAS)](https://learn.microsoft.com/en-us/azure/logic-apps/logic-apps-securing-a-logic-app?tabs=azure-portal#sas).

## Why set this?

By requiring inbound calls to be authentication, you ensure that only those systems that should be calling your logic app are calling it.

## Reference

* [Enable OAuth with Microsoft Entra ID for your Consumption logic app resource](https://learn.microsoft.com/en-us/azure/logic-apps/logic-apps-securing-a-logic-app?tabs=azure-portal#enable-azure-ad-inbound)
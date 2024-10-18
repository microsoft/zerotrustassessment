# 018: Networking

## Overview

Use Azure Virtual Networks to limit access to/from the Logic App.

## Zero Trust Pillars

* Assume breach

## What to do

* Use Virtual Networks if your Logic App does not need internet access
* Limit the IP Addresses that can be accessed .

## Why set this?

If your logic app is part of a virtual network, make sure to set the rules to limit which services can access the logic app and which services the logic app can access to minimize the area of attack.

## Reference

* [Secure traffic between Standard logic apps and Azure virtual networks using private endpoints](https://learn.microsoft.com/en-us/azure/logic-apps/secure-single-tenant-workflow-virtual-network-private-endpoint)
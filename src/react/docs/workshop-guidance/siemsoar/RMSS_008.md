# 008: API Connections

## Overview

API connections are used to connect Logic Apps to SaaS services, such as Office 365. It contains information provided when configuring access to a SaaS service and created in workflows.   Part of Connections in Standard Logic Apps

## Zero Trust Pillars

* Least Privileged Access
* Assume breach

## What to do

* Verify that the API connections are valid (don’t access unknown services)
* Verify that the Access Control entries for the API connections are correct
* Use managed identities when possible.  May need to use a user account for actions like sending an Email
* Periodically check to see if access is still needed (is the workflow still being used)

## Why set this?

By reducing the number of API Connections that the logic app has access to, you reduce the target area for bad actors to attack.  If a bad actor gains access to a logic app, by reducting the number of API connections, it will reduce the number of places they can go next.

## Reference

* [How to create API connection (Logic App consumption) using ARM REST API](https://techcommunity.microsoft.com/t5/azure-integration-services-blog/how-to-create-api-connection-logic-app-consumption-using-arm/ba-p/3567231)
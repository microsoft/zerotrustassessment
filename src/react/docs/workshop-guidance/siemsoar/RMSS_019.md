# 019: CORS

## Overview

Cross-Origin Resource Sharing (CORS) allows JavaScript code running in a browser on an external host to interact with your backend.  This can be a security risk as it allows systems to access your environment that you may not have intended.

## Zero Trust Pillars

* Assume breach

## What to do

* Avoid enabling unless required. Use only if your Logic App is being accessed externally
* Specify the origins can be allowed to use CORS to access your Logic App

## Why set this?

Minimize the use of CORS as it can allow external systems access to areas you may not have intended.  If required, specify which orgins can access your logic app to reduce the area of attack.

## Reference

* [Tutorial: Host a RESTful API with CORS in Azure App Service](https://learn.microsoft.com/en-us/azure/app-service/app-service-web-tutorial-rest-api)
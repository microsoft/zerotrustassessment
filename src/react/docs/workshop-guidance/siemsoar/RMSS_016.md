# 016: Parameters

## Overview

Use these parameters to pass information into the various workflows rather than having them hard-coded in the app

## Zero Trust Pillars

* Least Privileged Access
* Assume breach

## What to do

* Don’t set restricted data (i.e. username/password) in parameters, use Key Vaults instead
* Validate that the parameters do not store confidential information

## Why set this?

Hard coding data in your app will make it easier to obtain that data.  Use parameters to pass in the data or, better yet, store the data in a Key Vault.

## Reference

* [Edit host and app settings for Standard logic apps in single-tenant Azure Logic Apps](https://learn.microsoft.com/en-us/azure/logic-apps/edit-app-settings-host-settings?tabs=azure-portal)
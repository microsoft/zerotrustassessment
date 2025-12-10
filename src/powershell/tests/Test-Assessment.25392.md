The Private Network Connector is a key component of Entra Private Access and Entra Application Proxy. To maintain security, stability, and performance, it's essential that all connector machines run the latest software version. This check reviews every private network connector in your environment, compares the installed version with the most recent release, and flags any connectors that are not up to date. If any connector is outdated, the check will fail and provide a detailed list of current versions.

**Remediation action**

Please check this article which shows the release notes and latest version of the private network connector. 
- [Microsoft Entra private network connector version release notes - Global Secure Access](https://learn.microsoft.com/entra/global-secure-access/reference-version-history)

**Note**: Please be aware that not every connector update is an auto-update and some need to be applied manually. Auto-update will only work if the connector updater process on your machine is running.
<!--- Results --->
%TestResult%

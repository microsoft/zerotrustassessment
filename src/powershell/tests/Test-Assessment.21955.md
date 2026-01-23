When local administrators on Microsoft Entra joined devices are not managed by the organization, threat actors who could compromise user accounts can execute device takeover attacks that result in permanent loss of organizational control. Threat actors can leverage compromised account credentials to perform account manipulation by removing all organizational administrators from the device’s local administrators, including the global administrators who normally retain management access. Once threat actors do that, they can modify user account control settings and disable the device's connection to Microsoft Entra, effectively severing the cloud management channel. This attack progression results in a complete device takeover where organizational global administrators lose all administrative pathways to regain control. The device becomes an orphaned asset that cannot be managed anymore. 

**Remediation action**

- [Manage the local administrators on Microsoft Entra joined devices](https://learn.microsoft.com/en-us/entra/identity/devices/assign-local-admin)
<!--- Results --->
%TestResult%

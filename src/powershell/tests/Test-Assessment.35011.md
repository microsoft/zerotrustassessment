The super user feature of the Azure Rights Management service grants designated accounts the ability to decrypt content your organization has encrypted by using this service, regardless of the original permissions assigned. Super users might be necessary for eDiscovery, data recovery, compliance investigations, and content migration. The super user feature ensures that authorized people and services can always read and inspect the data that the Azure Rights Management service encrypts for your organization.

When you use a group to designate super user accounts, membership of that group must be carefully controlled and limited, for example, to service accounts used by compliance tools or eDiscovery platforms. Unless you have a feature or business need that requires the feature to be enabled all the time, Microsoft recommends keeping the feature disabled by default, and enabling it only when needed. When you use a group to designate super user accounts, use Microsoft Entra Privileged Identity Management (PIM) to reduce risk by enabling just‑in‑time access when required and minimizing permanent privilege.

**Remediation action**

- [Configure Azure Rights Management super users for discovery services or data recovery](https://learn.microsoft.com/purview/encryption-super-users?wt.mc_id=zerotrustrecommendations_automation_content_cnl_csasci#security-best-practices-for-the-super-user-feature)
<!--- Results --->
%TestResult%


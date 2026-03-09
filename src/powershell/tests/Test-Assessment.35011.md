The superuser feature of the Azure Rights Management service grants designated accounts the ability to decrypt all content protected by the organization, regardless of the original permissions assigned. Superusers enable eDiscovery, data recovery, compliance investigations, and content migration. Without this configuration, encrypted content can become permanently inaccessible when rights holders are unavailable.

Membership must be carefully controlled and limited to service accounts used by compliance tools or eDiscovery platforms. Microsoft recommends keeping the feature disabled by default and *enabling it only via Microsoft Entra Privileged Identity Management (PIM)* for just-in-time access.

**Remediation action**

- [Configure Azure Rights Management super users for discovery services or data recovery](https://learn.microsoft.com/purview/encryption-super-users?wt.mc_id=zerotrustrecommendations_automation_content_cnl_csasci#security-best-practices-for-the-super-user-feature)
<!--- Results --->
%TestResult%


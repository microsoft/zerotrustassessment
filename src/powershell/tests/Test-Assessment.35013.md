Without encryption, sensitivity labels denote an item's sensitivity level without preventing unauthorized access, unless supplemented by another protection mechanism. Sensitivity labels that are configured to apply encryption from the Azure Rights Management service enforce access control and usage rights. This protection persists regardless of where the content is stored or shared. For example, users can still share a document labeled as "Confidential", but if that label applies encryption, unauthorized people won't be able to open it.

Organizations using labels without encryption gain visibility of the sensitivity level but the labels themselves lack technical enforcement. Labels that apply encryption ensure only authorized users can decrypt content and use it with any restrictions that are specified for that user. For example, read-only, or prevent copying. This protection helps prevent data exfiltration even if files are leaked or improperly shared. At least one sensitivity label should be configured to apply encryption for high-value data that requires protection beyond identifying the sensitivity level.

**Remediation action**

- [Restrict access to content by using encryption in sensitivity labels](https://learn.microsoft.com/purview/encryption-sensitivity-labels?wt.mc_id=zerotrustrecommendations_automation_content_cnl_csasci)
<!--- Results --->
%TestResult%


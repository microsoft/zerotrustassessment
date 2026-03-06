Double Key Encryption (DKE) provides an extra layer of protection for highly sensitive data by requiring two keys to decrypt content: one managed by Microsoft and one by the customer. This "hold your own key" approach ensures Microsoft can't decrypt content even with legal compulsion, meeting stringent regulatory requirements for data sovereignty.

However, DKE introduces significant operational complexity including dedicated key service infrastructure, reduced feature compatibility, and increased support burden. Organizations should maintain 1-3 labels reserved for truly mission-critical or heavily regulated data, with documented business justification for each DKE label. Use standard encryption for general business content. Excessive DKE labels (4 or more) create management overhead, user confusion, and reduce collaboration. DKE should never be broadly deployed, as key service unavailability prevents access to business-critical documents.

**Remediation action**

- [Double Key Encryption](https://learn.microsoft.com/purview/double-key-encryption?wt.mc_id=zerotrustrecommendations_automation_content_cnl_csasci)
- [Set up Double Key Encryption](https://learn.microsoft.com/purview/double-key-encryption-setup?wt.mc_id=zerotrustrecommendations_automation_content_cnl_csasci)
<!--- Results --->
%TestResult%


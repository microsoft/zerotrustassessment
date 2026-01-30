Double Key Encryption (DKE) provides an additional layer of protection for highly sensitive data by requiring two keys to decrypt content: one managed by Microsoft and one managed by the customer. This "hold your own key" approach ensures Microsoft cannot decrypt customer content even with legal compulsion, meeting stringent regulatory requirements for data sovereignty and control. However, DKE introduces significant operational complexity including dedicated key service infrastructure, reduced feature compatibility, and increased support burden. Organizations that deploy DKE should maintain 1-3 labels reserved for truly mission-critical or heavily regulated data. Excessive DKE label proliferation (4 or more labels) indicates potential misuse and creates management overhead, user confusion about when to apply DKE versus standard encryption, and reduces collaboration capabilities. DKE should never be broadly deployed across general business content. Overuse of DKE creates operational risk where key service unavailability prevents access to business-critical documents.

**Remediation action**

To manage DKE labels:
1. Review existing DKE labels and consolidate where possible
2. Ensure DKE is only applied to labels protecting highly sensitive data with specific regulatory requirements
3. Consider standard encryption for general business content
4. Document business justification for each DKE label

To configure DKE (if needed):
1. Deploy DKE key service infrastructure
2. Create sensitivity label in compliance portal
3. Enable encryption with "Let users assign permissions"
4. Configure DKE settings with key service URL
5. Publish label through label policy

 - [Double Key Encryption](https://learn.microsoft.com/en-us/microsoft-365/compliance/double-key-encryption)
 - [Plan for DKE](https://learn.microsoft.com/en-us/purview/double-key-encryption-overview)

<!--- Results --->
%TestResult%

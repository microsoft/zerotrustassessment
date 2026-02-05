Sensitivity labels provide classification capabilities, but without encryption, labels merely mark content as sensitive without preventing unauthorized access. Encryption-enabled labels apply Azure Rights Management protection to documents and emails, enforcing access controls that persist with the content regardless of where it is stored or shared. Users with "Confidential" labels on documents can still forward those files to unauthorized recipients unless encryption prevents file access based on identity. Organizations investing in sensitivity label frameworks without enabling encryption gain visibility into data classification but lack technical enforcement of protection policies. Encrypted labels ensure that only authorized users and applications can decrypt content, preventing data exfiltration even if files are leaked, stolen, or improperly shared. At least one encryption-enabled label should exist for high-value data requiring protection beyond classification metadata.

**Remediation action**

To create or enable encryption on sensitivity labels:

1. Navigate to Microsoft Purview portal → Information Protection → Labels → Sensitivity labels
2. Create a new label or edit an existing label
3. Under label scope, ensure "Items" is selected (to apply encryption to files and emails)
4. In protection settings, select "Apply or remove encryption"
5. Configure encryption settings:
   - **Assign permissions now**: Define specific users/groups with explicit permissions
   - **Let users assign permissions**: Allow Do Not Forward or user-defined permissions per document
6. Select the encryption method:
   - **Standard RMS** (Template-based): Uses organization's default RMS templates
   - **Double Key Encryption (DKE)**: For highly sensitive data requiring customer-managed key (note: blocks co-authoring)
7. Save and publish the label to make it available to users

For detailed guidance 
- [Restrict access to content by using encryption in sensitivity labels](https://learn.microsoft.com/en-us/microsoft-365/compliance/encryption-sensitivity-labels)
<!--- Results --->
%TestResult%

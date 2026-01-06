# Encryption-Enabled Sensitivity Labels

## Description

Sensitivity labels provide classification capabilities, but without encryption, labels merely mark content as sensitive without preventing unauthorized access. Encryption-enabled labels apply Azure Rights Management protection to documents and emails, enforcing access controls that persist with the content regardless of where it is stored or shared.

Users with "Confidential" labels on documents can still forward those files to unauthorized recipients unless encryption prevents file access based on identity. Organizations investing in sensitivity label frameworks without enabling encryption gain visibility into data classification but lack technical enforcement of protection policies.

Encrypted labels ensure that only authorized users and applications can decrypt content, preventing data exfiltration even if files are leaked, stolen, or improperly shared. At least one encryption-enabled label should exist for high-value data requiring protection beyond classification metadata.

## How to fix

To enable encryption on sensitivity labels:

1. Navigate to **Microsoft Purview portal** → **Information protection** → **Labels**
2. Create a new label or edit an existing label
3. Under label scope, ensure **Items** is selected
4. In protection settings, enable **Apply or remove encryption**
5. Configure encryption settings:
   - **Assign permissions now** (define specific users/groups)
   - **Let users assign permissions** (Do Not Forward or user-defined)
6. Save and publish the label through a label policy

## Learn more

- [Restrict access to content by using encryption in sensitivity labels](https://learn.microsoft.com/en-us/microsoft-365/compliance/encryption-sensitivity-labels)
- [Apply encryption using sensitivity labels](https://learn.microsoft.com/en-us/purview/sensitivity-labels-office-apps)
- [Information protection in Microsoft 365](https://learn.microsoft.com/en-us/microsoft-365/compliance/information-protection)

When OCR (Optical Character Recognition) is not configured, organizations cannot detect sensitive information hidden within images embedded in documents, emails, and files across Microsoft 365 workloads. This creates a significant security gap because sensitive data frequently appears in scanned documents, screenshots, faxes, invoices, and other image-based content that text-only detection cannot identify. Without OCR, data loss prevention (DLP) policies, auto-labeling policies, and insider risk management policies cannot scan images for credit card numbers, personally identifiable information (PII), trade secrets, or other sensitive information types, leaving image-based sensitive data unprotected and unclassified. OCR configuration is a tenant-level setting that extends existing sensitive information type and trainable classifier detection to images across Exchange, SharePoint, OneDrive, Teams, and endpoint devices. Configuring OCR requires Azure pay-as-you-go billing for Microsoft Syntex, after which compliance administrators can enable OCR for specific locations and workloads. OCR enables DLP, auto-labeling, records management, and insider risk management policies to scan images for sensitive content automatically without requiring additional policy configuration.

**Remediation action**

**Remediation Steps:**
- Set up Azure billing for Microsoft Syntex (required for OCR) at [Set up Microsoft Syntex billing in Azure](https://learn.microsoft.com/en-us/microsoft-365/syntex/syntex-azure-billing)
- Use [OCR Cost Estimator](https://learn.microsoft.com/en-us/purview/ocr-cost-estimator) to estimate charges ($1.00 per 1,000 items)
- Sign into [Microsoft Purview portal](https://purview.microsoft.com/) as Compliance Admin
- Navigate to Settings > Optical Character Recognition (OCR)
- Select locations for OCR scanning (Exchange, SharePoint, OneDrive, Teams, Endpoint)
- Click Enable and save changes (takes ~1 hour to take effect)


**Best Practices:**
- Start with OCR enabled for Exchange and SharePoint to cover high-risk content types (email, shared documents)
- Consider scoping OCR to high-risk user groups or departments to reduce scanning costs and focus on sensitive data locations
- Allow 1-2 weeks for OCR to process historical content before evaluating effectiveness
- Combine OCR with DLP policies that include image-based sensitive information types (credit card numbers, PII, etc.)
- Regularly review OCR costs and scanning activity in the Purview portal
- Use endpoint OCR cautiously due to device resource impact and bandwidth requirements (default limit: 1,024 MB/device/day)
- Ensure adequate Azure subscription budget allocation for OCR scanning charges
- Consider using trainable classifiers combined with OCR for complex image content detection

**Learn More:** 
- [Configure your OCR settings](https://learn.microsoft.com/en-us/purview/ocr-learn-about#configure-your-ocr-settings)

<!--- Results --->
%TestResult%

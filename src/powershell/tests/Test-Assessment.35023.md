When OCR (Optical Character Recognition) is not configured, organizations cannot detect sensitive information hidden within images embedded in documents, emails, and files across Microsoft 365 workloads. This creates a significant security gap because sensitive data frequently appears in scanned documents, screenshots, faxes, invoices, and other image-based content that text-only detection cannot identify. Without OCR, data loss prevention (DLP) policies, auto-labeling policies, and insider risk management policies cannot scan images for credit card numbers, personally identifiable information (PII), trade secrets, or other sensitive information types, leaving image-based sensitive data unprotected and unclassified. OCR configuration is a tenant-level setting that extends existing sensitive information type and trainable classifier detection to images across Exchange, SharePoint, OneDrive, Teams, and endpoint devices. Configuring OCR requires Azure pay-as-you-go billing for Microsoft Syntex, after which compliance administrators can enable OCR for specific locations and workloads. OCR enables DLP, auto-labeling, records management, and insider risk management policies to scan images for sensitive content automatically without requiring additional policy configuration.

**Remediation action**

- Set up Azure billing for Microsoft Syntex (required for OCR) at [Set up Microsoft Syntex billing in Azure](https://learn.microsoft.com/en-us/microsoft-365/syntex/syntex-azure-billing)
- Use [OCR Cost Estimator](https://learn.microsoft.com/en-us/purview/ocr-cost-estimator) to estimate charges ($1.00 per 1,000 items)
- Sign into [Microsoft Purview portal](https://purview.microsoft.com/) as Compliance Admin
- Navigate to Settings > Optical Character Recognition (OCR)
- Select locations for OCR scanning (Exchange, SharePoint, OneDrive, Teams, Endpoint)
- Click Enable and save changes (takes ~1 hour to take effect)

**Learn More:** 
- [Configure your OCR settings](https://learn.microsoft.com/en-us/purview/ocr-learn-about#configure-your-ocr-settings)

**To configure OCR for automatic detection of sensitive information within images:**

1. Verify Azure billing prerequisites by working with your Global Administrator to ensure a Microsoft Syntex pay-as-you-go Azure subscription is set up and linked to your Microsoft 365 tenant. Follow [Set up Microsoft Syntex billing in Azure](https://learn.microsoft.com/en-us/microsoft-365/syntex/syntex-azure-billing). Use the [OCR Cost Estimator](https://learn.microsoft.com/en-us/purview/ocr-cost-estimator) to estimate expected charges based on your organization's image volume ($1.00 per 1,000 items scanned).

2. Access OCR settings in the Microsoft Purview portal by signing in as a Compliance Administrator or Global Administrator, then navigating to Settings > Optical character recognition (OCR).

3. Select workload locations for OCR scanning. Choose from Exchange (email scanning), SharePoint (site file scanning), OneDrive (personal file scanning), Teams (chat/channel message scanning), and Endpoint devices (Windows/macOS document scanning). Start with high-risk locations (Exchange for email-based threats, SharePoint for shared content) to maximize security impact while managing costs.

4. Enable OCR by clicking the enable button in the OCR configuration page. Configuration changes take effect approximately one hour after being saved. Wait one hour, then re-run the assessment to verify OCR is active: `Get-OcrConfiguration` should return Enabled = true and IsOcrUsageBlocked = false.

**Best Practices:**
- Start with OCR enabled for Exchange and SharePoint to cover high-risk content types (email, shared documents)
- Consider scoping OCR to high-risk user groups or departments to reduce scanning costs and focus on sensitive data locations
- Allow 1-2 weeks for OCR to process historical content before evaluating effectiveness
- Combine OCR with DLP policies that include image-based sensitive information types (credit card numbers, PII, etc.)
- Regularly review OCR costs and scanning activity in the Purview portal
- Use endpoint OCR cautiously due to device resource impact and bandwidth requirements (default limit: 1,024 MB/device/day)
- Ensure adequate Azure subscription budget allocation for OCR scanning charges
- Consider using trainable classifiers combined with OCR for complex image content detection


<!--- Results --->
%TestResult%

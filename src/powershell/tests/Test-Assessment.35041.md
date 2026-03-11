Browser Data Loss Prevention (DLP) for cloud apps in Microsoft Edge for Business prevents users from uploading, downloading, copying, or pasting sensitive data to and from unmanaged cloud AI services (ChatGPT, Google Gemini, Claude, etc.) directly through the browser. Without Browser DLP policies for AI apps configured, users can access consumer AI services through Edge for Business and exfiltrate sensitive organizational data by uploading files or pasting confidential information, circumventing cloud-based DLP controls.

Browser DLP acts as the final enforcement point at the browser level, blocking data transfers to AI services even if data governance policies allow access to the service itself. Organizations using Microsoft 365 Copilot or allowing employee access to generative AI tools must enable Browser DLP policies targeting unmanaged AI apps to prevent uncontrolled data exposure. Browser DLP for AI apps requires PAYG billing activation, Intune-managed devices, and Edge for Business deployment to function.

**Remediation action**

**To enable Browser DLP for AI Apps (Minimal Setup):**

1. **Activate PAYG Billing** (One-time setup)
   - Navigate to [Purview Settings > Account](https://purview.microsoft.com/settings/account)
   - Enable "Purview Pay-as-You-Go billing"
   - Activate trial or start paid subscription
   - This is the only hard requirement

2. **Create Browser DLP Policy** (via Purview UI)
   - Navigate to [Microsoft Purview portal](https://purview.microsoft.com)
   - Data Loss Prevention > Policies > + Create policy
   - Choose "Custom" policy template
   - Name: "Browser DLP - AI Apps" (or similar)
   - Add locations: Select "Edge for Business"
   - Add cloud apps: Select "All unmanaged AI apps" OR add specific apps manually
   - Configure scope: All users or specific groups
   - Create rule:
     - Name: "Block Sensitive Data to Unmanaged AI Apps"
     - Condition: Content contains [pick sensitive info types: credit card, SSN, bank account, etc.]
     - Action: "Restrict browser activities" > Block file uploads and text sharing to unmanaged apps
   - Incident reports: Enable alerts for rule matches
   - Policy mode: Start with "Simulate" (TestWithoutNotifications) for testing
   - Enable policy

3. **Deployment Requirements**
   - Managed devices: Intune enrollment required (Windows 10/11)
   - Browser: Edge for Business v144+
   - Microsoft Edge management automatically syncs policy

4. **Validation**
   - Navigate to Activity Explorer in Purview
   - Filter: Enforcement Plane = "Browser"
   - Monitor for browser DLP activities
   - Review [Microsoft Defender](https://security.microsoft.com) for related alerts

**Optional Enhancement: Add Collection Policies** (Data classification layer)
- If you want more granular data classification, create collection policies targeting AI apps
- Collection policies define what data to monitor (optional for basic protection)
- Link collection policies to Browser DLP rules (if UI supports linking)

**Via PowerShell (After PAYG activation):**
```powershell
Connect-ExchangeOnline
Connect-IPPSSession

# List browser DLP policies
Get-DlpCompliancePolicy | Where-Object { $_.EnforcementPlanes -contains "Browser" } | Select-Object Name, Enabled, Mode

# Enable specific policy
Set-DlpCompliancePolicy -Identity <PolicyGUID> -Enabled $true

# List rules for browser policy
Get-DlpCompliancePolicy | Where-Object { $_.EnforcementPlanes -contains "Browser" } | ForEach-Object { Get-DlpComplianceRule -Policy $_.Identity }
```

**For more information:**
- [Learn about Browser DLP for Cloud Apps](https://learn.microsoft.com/en-us/purview/dlp-browser-dlp-learn)
- [Create policy for browser cloud app protection](https://learn.microsoft.com/en-us/purview/dlp-create-policy-prevent-cloud-sharing-from-edge-biz)
- [Create policy for AI app protection](https://learn.microsoft.com/en-us/purview/dlp-create-policy-block-to-ai-via-edge)
- [Billing and PAYG activation](https://learn.microsoft.com/en-us/purview/purview-billing-models)
<!--- Results --->
%TestResult%

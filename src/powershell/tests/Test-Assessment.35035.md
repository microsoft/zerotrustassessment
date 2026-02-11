Named Entity Sensitive Information Types (SITs) are pre-built, Microsoft-managed classifiers designed to detect common sensitive entities like people's names, physical addresses, and medical terminology. Unlike custom SITs that organizations create for specific business needs, Named Entity SITs are provided by Microsoft and enable organizations to implement sophisticated data protection without requiring custom development. By configuring Named Entity SITs in auto-labeling policies and DLP rules, organizations can automatically classify and protect content containing sensitive personal information, employee data, and domain-specific terminology. This transforms data protection from purely technical pattern-matching (like detecting credit card numbers or social security numbers) into intelligent, semantically-aware classification systems that understand context. Organizations handling content with sensitive entity information—executive communications, customer data, medical records, or other high-sensitivity content—should deploy at least one Named Entity SIT in their protection policies. Demonstrating Named Entity SIT deployment shows sophisticated, context-aware information protection beyond basic generic SIT detection.

**Remediation action**

To deploy Named Entity SITs in your policies:

**Option 1: Deploy via DLP Policy**
1. Sign in as Global Administrator or Compliance Administrator to the [Microsoft Purview portal](https://purview.microsoft.com)
2. Navigate to [DLP Policies](https://purview.microsoft.com/datalossprevention/policies)
3. Create a new DLP policy or edit an existing one
4. Add a rule with condition: "Content contains sensitive information"
5. Select Named Entity SITs from the dropdown:
   - **All Full Names** - Detects common and uncommon full names worldwide
   - **All Physical Addresses** - Detects addresses in various formats
   - **All Medical Terms and Conditions** - Detects medical terminology and conditions
   - **Country/Region-Specific Variants** - e.g., "Austria Physical Addresses", "Canada Physical Addresses"
6. Configure the action (notify user, restrict access, send alert, etc.)
7. Specify the workload scope (Exchange, SharePoint, OneDrive, Teams, Power BI)
8. Enable and deploy the policy

**Option 2: Deploy via Auto-Labeling Policy**
1. Navigate to [Auto-Labeling Policies](https://purview.microsoft.com/informationprotection/autolabeling)
2. Create a new auto-labeling policy or edit an existing one
3. In the rule configuration, add a condition: "Content contains sensitive information"
4. From the sensitive information types list, select Named Entity SITs (e.g., "All Full Names")
5. Configure the sensitivity label to apply when content matches
6. Set the policy scope (Exchange, SharePoint, OneDrive, Teams, Power BI, or All)
7. Enable and deploy the policy

**View Available Named Entity SITs:**
- Navigate to [Sensitive Information Types](https://purview.microsoft.com/informationprotection/dataclassification/multicloudsensitiveinfotypes)
- Named Entity SITs have `Classifier: EntityMatch` in their properties

**Query via PowerShell:**
```powershell
Connect-IPPSSession
Get-DlpSensitiveInformationType | Where-Object { $_.Classifier -eq "EntityMatch" } | Select-Object Name, Classifier, Capability
```

**Example Scenarios:**
- **Protect Executive Communications**: Auto-label emails containing "All Full Names" with "Executive Communications" label
- **Protect Healthcare Records**: DLP rule blocking external sharing of content with "All Medical Terms and Conditions"
- **Address Data Protection**: DLP rule restricting content with "All Physical Addresses" to internal sharing only

<!--- Results --->
%TestResult%

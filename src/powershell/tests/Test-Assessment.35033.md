Custom Sensitive Information Types (SITs) are organization-specific classification rules that detect patterns of sensitive data beyond the built-in SIT library. Custom SITs enable organizations to identify proprietary data formats, business-specific terminology, regulatory identifiers, or internal classification schemes that are unique to their industry or operations. By creating custom SITs, organizations can extend Microsoft Purview's data discovery capabilities to automatically detect and protect organization-specific sensitive information in auto-labeling policies, Data Loss Prevention (DLP) rules, and communication compliance monitoring. Custom SITs are particularly critical for organizations handling proprietary data formats, internal identifiers, specialized healthcare codes, financial account numbers, or regulatory compliance data that doesn't match standard built-in patterns. Without custom SITs, data protection mechanisms rely exclusively on generic patterns and may miss organization-specific sensitive information that requires targeted protection.

**Remediation action**

To create custom Sensitive Information Types:

1. Sign in as a Global Administrator or Compliance Administrator to the [Microsoft Purview portal](https://purview.microsoft.com)
2. Navigate to Data Classification > Sensitive Info Types
3. Select "+ Create sensitive info type" to create a new custom SIT
4. Enter a name and description for your custom SIT
5. Define detection patterns:
   - **Regex pattern**: Define a regular expression to match the data format
   - **Keyword list**: Create a list of specific terms or identifiers to match
   - **Supporting evidence**: Add additional patterns that provide confidence to the match
6. Set confidence level (Low, Medium, High) based on pattern specificity
7. Define character proximity for multi-pattern matching
8. Test the pattern with sample data to verify accuracy
9. Create and activate the custom SIT
10. Use the custom SIT in auto-labeling policies or DLP rules

Example custom SIT patterns:
- **Internal Project Codes**: Regex pattern matching "PROJ-[0-9]{6}" format
- **Employee ID Numbers**: Regex pattern matching "EMP-[0-9]{8}" format
- **Healthcare Record Numbers**: Regex pattern matching proprietary medical record identifiers
- **Financial Account Numbers**: Regex pattern matching internal bank account formats
- **Regulatory Reference Numbers**: Keyword lists or patterns specific to industry compliance codes

Alternatively, create via PowerShell:
1. Connect to Compliance & Security PowerShell: `Connect-IPPSSession`
2. Custom SITs cannot be created directly via PowerShell; use the portal for creation
3. Verify creation: `Get-DlpSensitiveInformationType -Filter "IsBuiltIn -eq $false"`

- [Create and configure custom sensitive information types](https://learn.microsoft.com/en-us/purview/create-a-custom-sensitive-information-type)
- [Sensitive information types (SITs) reference](https://learn.microsoft.com/en-us/purview/sit-learn-about-exact-data-match-based-sits)
- [Regular expressions for custom SITs](https://learn.microsoft.com/en-us/purview/sensitive-information-type-entity-definitions)
<!--- Results --->
%TestResult%

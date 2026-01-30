Exact Data Match (EDM) is an advanced Sensitive Information Type (SIT) that enables organizations to detect highly specific, organization-proprietary data formats by matching exact patterns against an uploaded reference database. Unlike pattern-based SITs that match credit card numbers, SSNs, or other generic formats, EDM can identify customer lists, employee IDs with specific internal formats, proprietary product codes, or confidential identifiers that follow organization-specific patterns. EDM requires uploading a reference dataset (hash of sensitive data) that the system compares against to identify exact matches in organization content. Without EDM configured, organizations cannot detect proprietary or highly specific sensitive data that doesn't match standard built-in SIT patterns, leaving critical organizational data at risk. EDM configurations enable precise, low-false-positive detection of organization-specific sensitive information in auto-labeling policies and DLP rules. Organizations handling proprietary data, internal reference numbers, or specialized identifiers should implement EDM to achieve granular detection and protection that pattern-based SITs cannot provide. Configuring at least one EDM schema demonstrates commitment to comprehensive data protection that covers both standard and organization-specific sensitive data types.

**Remediation action**

To configure Exact Data Match (EDM) schemas:

1. Sign in as a Global Administrator or Compliance Administrator to the [Microsoft Purview portal](https://purview.microsoft.com)
2. Navigate to Information Protection > Classifiers > EDM classifiers
3. Click "+ Create EDM classifier"
4. Enter classifier name and description
5. Define the schema structure:
   - Upload or import a CSV file containing sample sensitive data
   - Map CSV columns to schema fields (e.g., Column 1 = Employee ID, Column 2 = Department)
   - Select which columns are searchable (fields to match against)
   - Define which columns are optional vs. required
6. Configure EDM-sensitive information type:
   - Create a new SIT or assign to existing SIT
   - Set match proximity for multi-field matching
   - Add optional confirming evidence (keywords that increase confidence)
7. Upload the reference data file:
   - File must be in CSV format (UTF-8 encoding)
   - Contains the exact sensitive data values to be detected
   - File is hashed for privacy; actual data not stored
8. Select scope for EDM detection:
   - Choose workloads: Exchange, SharePoint, OneDrive, Teams
   - Select applies to all locations or specific locations
9. Enable the EDM schema
10. Integrate EDM SIT into auto-labeling policies or DLP rules

**Example EDM schemas:**
- **Customer List**: CSV with customer IDs, names, account numbers
- **Employee Database**: CSV with employee IDs, email addresses
- **Product Codes**: CSV with internal product SKUs and identifiers
- **Financial Accounts**: CSV with bank account numbers, routing numbers
- **Vendor Information**: CSV with vendor codes and contract identifiers

**EDM reference file best practices:**
- Include 5-100 example records for testing
- Use UTF-8 encoding without BOM
- Include headers in first row
- Keep sensitive data secure during upload
- Update reference file periodically as sensitive data changes

**Create via PowerShell:**
```powershell
# Connect to Exchange Online
Connect-IPPSSession

# Create EDM schema
New-DlpEdmSchema -Name "Customer IDs" -Schema @(@{ColumnName="CustomerID";Searchable=$true})

# Upload reference data
Set-DlpEdmSchema -Identity "Customer IDs" -DataFile "C:\reference-data.csv"

# Verify configuration
Get-DlpEdmSchema | Format-List
```

**Resources:**
- [Exact Data Match (EDM) Overview](https://learn.microsoft.com/en-us/purview/sit-learn-about-exact-data-match-based-sits)
- [Create EDM schemas](https://learn.microsoft.com/en-us/purview/sit-get-started-exact-data-match-based-sits-overview)
- [EDM SIT integration with DLP](https://learn.microsoft.com/en-us/purview/dlp-create-deploy-policy)
<!--- Results --->
%TestResult%

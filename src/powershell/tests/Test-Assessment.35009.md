Co-authoring allows multiple users to simultaneously edit Office documents stored in SharePoint and OneDrive. When sensitivity labels apply encryption to documents, co-authoring capabilities are disabled by default, forcing users to work sequentially rather than collaboratively. Without co-authoring enabled for encrypted files, users face productivity barriers that incentivize removing encryption or working with unprotected copies to maintain collaboration velocity. The EnableLabelCoauth tenant-wide setting allows co-authoring on encrypted documents while maintaining protection and access controls defined by sensitivity labels.

**Remediation action**

To enable co-authoring for encrypted documents:

1. Connect to Security & Compliance PowerShell: `Connect-IPPSSession`
2. Run the command: `Set-PolicyConfig -EnableLabelCoauth $true`
3. Wait for replication (changes may take up to 24 hours to propagate fully)
4. Users may need to sign out and sign back in to Office applications

- [Enable co-authoring for encrypted documents](https://learn.microsoft.com/en-us/purview/sensitivity-labels-coauthoring)
- [Set-PolicyConfig cmdlet reference](https://learn.microsoft.com/en-us/powershell/module/exchange/set-policyconfig)
<!--- Results --->
%TestResult%

When users attach sensitive documents to emails, the email container should inherit the highest classification level from its attachments to maintain consistent data protection. Without email label inheritance from attachments enabled, users may send unlabeled or under-labeled emails containing highly sensitive attachments, creating a mismatch between the email's visibility (Subject, To, From) and the actual content sensitivity inside. Email label inheritance automatically applies the attachment's label (or higher priority label if multiple attachments exist) to the email message, ensuring the email itself reflects the sensitivity of its contents and receives appropriate protection (encryption, watermarking, etc.). This prevents accidental data exposure by ensuring the email's protection level matches its attachments.

**Remediation action**

**To enable email label inheritance from attachments:**

1. **Verify Label Scope** (One-time setup)
   - Navigate to [Microsoft Purview → Information Protection → Labels](https://purview.microsoft.com/informationprotection/labels)
   - Select a label (or create new)
   - In the scope page: Verify BOTH "Files & other data assets" AND "Emails" are selected
   - If only "Files" is selected, edit and add "Emails" scope
   - Example labels to configure: General, Internal, Confidential, Highly Confidential

2. **Enable Inheritance in Label Policy**
   - Navigate to [Label policies](https://purview.microsoft.com/informationprotection/labelpolicies)
   - Select or create a policy that includes dual-scoped labels
   - Edit the policy and go to "Default settings for emails" page
   - Under "Inherit label from attachments" section:
     - ✓ Check "Email inherits highest priority label from attachments"
     - (Optional) Check "Recommend users apply the attachments label instead of automatically applying it" for opt-in behavior
   - Click Publish

3. **Verify Configuration**
   - In Outlook, create an email
   - Attach a document with a sensitivity label (e.g., labeled file from SharePoint)
   - Observe: Email should automatically show the inherited label (or show recommendation)
   - Send the email to verify inheritance and encryption work as expected

4. **User Communication**
   - Inform users that emails will now automatically inherit attachment labels
   - Explain they can still manually change labels before sending
   - Document the label hierarchy/priority so users understand which label "wins" with multiple attachments

**Via PowerShell** (advanced):
```powershell
Connect-IPPSSession

# List all labels with Files & Emails scope
Get-Label | Where-Object { 
    $_.ContentType -like '*File*' -and $_.ContentType -like '*Email*' 
} | Select-Object DisplayName, ContentType

# List all label policies with attachmentaction setting
Get-LabelPolicy | Where-Object { $_.Enabled -eq $true } | ForEach-Object { 
    $policyName = $_.Name
    $_.Settings | Where-Object { $_ -like "*attachmentaction*" } | ForEach-Object { 
        "$policyName : $_" 
    } 
}

# Enable email inheritance via PowerShell on a policy
Set-LabelPolicy -Identity "Global Policy" `
    -AdvancedSettings @{AttachmentAction="Automatic"}
```

**For more information:**
- [Configure label inheritance from email attachments](https://learn.microsoft.com/en-us/purview/sensitivity-labels-office-apps#configure-label-inheritance-from-email-attachments)
- [Scope labels to just files or emails](https://learn.microsoft.com/en-us/purview/sensitivity-labels-office-apps#scope-labels-to-just-files-or-emails)
- [Label priority (order matters)](https://learn.microsoft.com/en-us/purview/sensitivity-labels#label-priority-order-matters)

<!--- Results --->
%TestResult%

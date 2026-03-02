NSG Flow Logs record information about IP traffic flowing through Network Security Groups, providing essential visibility into network activity. Without flow logging, security teams cannot:

- **Investigate security incidents** — Flow logs provide the forensic data needed to trace lateral movement, data exfiltration, and unauthorized access attempts.
- **Detect anomalous traffic patterns** — Traffic Analytics (built on flow logs) uses machine learning to identify suspicious traffic flows and compromised hosts.
- **Meet compliance requirements** — Regulatory frameworks (PCI DSS, HIPAA, SOC 2, NIST) require network traffic logging and retention for audit purposes.
- **Validate network security rules** — Flow logs confirm whether NSG rules are working as intended by showing allowed and denied traffic.

Zero Trust principles require continuous monitoring and verification of all network activity. NSG Flow Logs provide the network-level telemetry needed to detect threats, validate policies, and support incident response.

**Remediation action**

To enable NSG Flow Logs:

1. Navigate to the [Azure portal Network Watcher blade](https://portal.azure.com/#browse/Microsoft.Network%2FnetworkWatchers%2FflowLogs).
2. Click **+ Create** to create a new flow log.
3. Select the **target NSG** to monitor.
4. Choose a **Storage Account** for log storage.
5. Set **Retention** to at least 90 days for compliance.
6. Enable **Traffic Analytics** for automated traffic analysis and threat detection.

To enable NSG Flow Logs using the Azure CLI:

```bash
az network watcher flow-log create \
    --resource-group <resource-group> \
    --nsg <nsg-name> \
    --name <flow-log-name> \
    --storage-account <storage-account-id> \
    --enabled true \
    --retention 90 \
    --workspace <log-analytics-workspace-id> \
    --traffic-analytics true
```

To enable flow logs using Azure PowerShell:

```powershell
$nsg = Get-AzNetworkSecurityGroup -Name <nsg-name> -ResourceGroupName <resource-group>
$storageAccount = Get-AzStorageAccount -Name <storage-account> -ResourceGroupName <resource-group>
$workspace = Get-AzOperationalInsightsWorkspace -Name <workspace-name> -ResourceGroupName <resource-group>

New-AzNetworkWatcherFlowLog `
    -NetworkWatcherName <network-watcher-name> `
    -ResourceGroupName NetworkWatcherRG `
    -Name <flow-log-name> `
    -TargetResourceId $nsg.Id `
    -StorageId $storageAccount.Id `
    -Enabled $true `
    -RetentionInDays 90 `
    -EnableTrafficAnalytics `
    -TrafficAnalyticsWorkspaceId $workspace.ResourceId
```

For more information, refer to the following Microsoft Learn documentation:

- [NSG flow logs overview](https://learn.microsoft.com/en-us/azure/network-watcher/nsg-flow-logs-overview)
- [Create NSG flow logs](https://learn.microsoft.com/en-us/azure/network-watcher/nsg-flow-logs-portal)
- [Traffic Analytics overview](https://learn.microsoft.com/en-us/azure/network-watcher/traffic-analytics)
- [Azure network security best practices](https://learn.microsoft.com/en-us/azure/security/fundamentals/network-best-practices)

<!--- Results --->
%TestResult%

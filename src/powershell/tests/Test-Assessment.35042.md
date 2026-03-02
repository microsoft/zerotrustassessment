Network Security Groups (NSGs) are a fundamental layer of defense for controlling inbound and outbound network traffic to Azure resources. Allowing inbound traffic on commonly exploited ports creates significant security risks:

- **FTP (port 21)** — Transmits credentials in plaintext, vulnerable to man-in-the-middle attacks.
- **SSH (port 22)** — While encrypted, direct internet exposure invites brute-force credential attacks.
- **Telnet (port 23)** — Transmits all data including credentials in plaintext with no encryption.
- **RPC (ports 135, 139)** — Remote Procedure Call ports frequently exploited for lateral movement.
- **SMB (port 445)** — Server Message Block is a common vector for ransomware propagation (e.g., WannaCry, NotPetya).
- **RDP (port 3389)** — Remote Desktop Protocol is one of the most targeted ports for brute-force and credential stuffing attacks.
- **Wildcard (*)** — Allowing all ports removes all network-level protection.

Zero Trust principles require that network access be explicitly verified and minimally scoped. Instead of exposing these ports directly, use secure alternatives such as Azure Bastion for RDP/SSH access, Just-in-Time (JIT) VM access through Microsoft Defender for Cloud, or Azure Private Link for service connectivity.

**Remediation action**

To secure NSGs with insecure inbound rules:

1. Navigate to the [Azure portal Network Security Groups blade](https://portal.azure.com/#browse/Microsoft.Network%2FnetworkSecurityGroups).
2. Select each NSG identified in the assessment results.
3. Go to **Inbound security rules**.
4. For each insecure rule, either **delete** the rule or **restrict** the source IP addresses to known, trusted ranges.
5. Replace direct port exposure with secure alternatives:
   - For RDP/SSH: Use [Azure Bastion](https://learn.microsoft.com/en-us/azure/bastion/bastion-overview) or [JIT VM Access](https://learn.microsoft.com/en-us/azure/defender-for-cloud/just-in-time-access-usage).
   - For application connectivity: Use [Azure Private Link](https://learn.microsoft.com/en-us/azure/private-link/private-link-overview).

To remove an insecure rule using the Azure CLI:

```bash
az network nsg rule delete --resource-group <resource-group> --nsg-name <nsg-name> --name <rule-name>
```

To restrict a rule to specific source IPs using Azure PowerShell:

```powershell
$nsg = Get-AzNetworkSecurityGroup -Name <nsg-name> -ResourceGroupName <resource-group>
$rule = $nsg.SecurityRules | Where-Object { $_.Name -eq '<rule-name>' }
$rule.SourceAddressPrefix = '<trusted-ip-range>'
Set-AzNetworkSecurityGroup -NetworkSecurityGroup $nsg
```

For more information, refer to the following Microsoft Learn documentation:

- [Network security groups overview](https://learn.microsoft.com/en-us/azure/virtual-network/network-security-groups-overview)
- [Azure Bastion overview](https://learn.microsoft.com/en-us/azure/bastion/bastion-overview)
- [Just-in-Time VM access in Microsoft Defender for Cloud](https://learn.microsoft.com/en-us/azure/defender-for-cloud/just-in-time-access-usage)
- [Azure network security best practices](https://learn.microsoft.com/en-us/azure/security/fundamentals/network-best-practices)

<!--- Results --->
%TestResult%

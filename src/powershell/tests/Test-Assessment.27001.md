When TLS inspection is enabled in Global Secure Access, traffic passing through the Security Service Edge undergoes decryption to enable deep packet inspection, URL categorization, and threat detection. Bypass rules are sometimes necessary for traffic that cannot be inspected due to technical constraints (certificate pinning) or compliance requirements. However, without regular review, bypass rules accumulate over time as temporary exceptions become permanent, applications are decommissioned while their bypass rules remain, or initial justifications become obsolete. Threat actors specifically target uninspected traffic channels, knowing that malware command-and-control communications, data exfiltration, and credential theft over HTTPS will evade detection when traffic bypasses TLS inspection. A policy that has not been modified in over 90 days may contain stale bypass rules that no longer serve a valid business purpose, effectively creating blind spots in the organization's network security posture. Organizations should maintain a review cadence where TLS inspection policies are audited quarterly at minimum, validating that each bypass rule remains necessary and appropriately scoped.

**Remediation action**

1. [Review and manage TLS inspection policies in the Microsoft Entra admin center under Global Secure Access > Secure > TLS inspection](https://learn.microsoft.com/en-us/graph/api/resources/networkaccess-tlsinspectionpolicy)
2. [Understand TLS inspection rule configuration and bypass actions](https://learn.microsoft.com/en-us/graph/api/resources/networkaccess-tlsinspectionrule)
3. Establish a quarterly review process for TLS inspection bypass rules, documenting business justification for each bypass rule and removing rules that are no longer necessary
4. Required role: Global Secure Access Administrator or Security Administrator

<!--- Results --->
%TestResult%

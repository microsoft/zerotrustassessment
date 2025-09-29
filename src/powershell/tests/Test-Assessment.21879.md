## Overview

Without enforced approval on entitlement management policies that allow external users, a threat actor can self-orchestrate initial access by submitting unattended requests that are auto-approved. Each successful request provisions or reuses a guest user object and grant access to resources included in the access package, immediately expanding reconnaissance surface. From that foothold the actor can enumerate additional collaboration surfaces, harvest shared files, and probe mis-scoped app permissions to escalate (e.g., abusing over-privileged group-based roles or app role assignments). They can persist by requesting multiple packages with overlapping or escalating privileges, re-extending assignments if expiration or reviews are lax, or by creating indirect sharing links inside granted SharePoint or Teams resources. Absence of an approval gate also removes a human anomaly check (sponsor/internal/external approver) that would otherwise filter suspicious volume, timing, geography, or improbable justification patterns, shrinking detection dwell-time. This accelerates lateral movement (pivoting through granted group memberships to additional workloads), facilitates data staging and exfiltration from SharePoint/Teams or app APIs, and increases the blast radius before downstream controls (access reviews, expirations) eventually trigger. Microsoft’s guidance explicitly states approval should be required when external users can request access to ensure oversight; bypassing it effectively converts a governed onboarding path into an unsupervised provisioning for external identities, expanding tenant-wide risk until manual discovery or periodic governance cycles intervene.

**Remediation action**

- [Configure approval for external request policies (toggle Require approval)](https://learn.microsoft.com/en-us/entra/id-governance/entitlement-management-access-package-approval-policy )


<!--- Results --->
%TestResult%

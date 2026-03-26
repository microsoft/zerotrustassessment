# Manage and Monitor Usage of Security Compute Units (SCUs)

**Implementation Effort:** Medium — Administrators only need to perform targeted actions in the Security Copilot or Azure portal to view usage or adjust capacity.  
**User Impact:** Low — Only administrators make changes; non-privileged users do not need to take any action.

## Overview
Security Compute Units (SCUs) define the processing capacity available to Microsoft Security Copilot. They determine how many security analyses, reasoning tasks, and automated workflows the service can run. Administrators can view real‑time and historical SCU consumption through built‑in dashboards in both the Security Copilot portal and the Azure portal. They can also scale SCUs up or down to meet operational needs.

If SCU usage is not monitored or managed, organizations risk hitting capacity limits, which can delay or block Copilot‑assisted investigations, threat analysis, and automated responses. Ensuring SCU capacity is healthy supports the Zero Trust *Assume Breach* principle by maintaining continuous operational readiness for detection and response workflows.

### Where to enable or configure
- **Security Copilot Portal** → Usage dashboard (shows SCU consumption trends).  
- **Azure Portal** → Security Copilot resource → **Capacity** (modify provisioned SCUs).


## Reference
- [Manage security compute unit usage in Security Copilot](https://learn.microsoft.com/en-us/copilot/security/manage-usage)  
- [Security Compute Units and capacity in Microsoft Security Copilot](https://learn.microsoft.com/en-us/copilot/security/security-compute-units-capacity)
  

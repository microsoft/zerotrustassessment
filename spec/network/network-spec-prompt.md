# Network Pillar Spec Creation Prompt

## Purpose

This prompt is specifically designed to guide the creation of high-quality specification documents for the **Network pillar** of the Zero Trust Assessment. It extends the general `spec-prompt.md` with Network pillar-specific guidance, focusing on Entra-based network configurations, Global Secure Access, Private Access, and related network security checks.

## Target Scope

This prompt is used when:
- Creating specs that validate Entra/Microsoft Entra network security configurations
- Checking Global Secure Access (GSA) and Private Access deployments
- Validating network segmentation, encryption, and access policies
- Assessing DDoS protection, firewalls, and network threat detection
- Verifying Zero Trust Network Access (ZTNA) implementations

## Input Format

Provide a **best practice statement** following this pattern:

```
[Network component or capability] should/must [security outcome or configuration]
```

### Examples:
- "Global Secure Access Private Access should be enabled for remote application access"
- "Azure DDoS Standard protection must be enabled on public-facing virtual networks"
- "Microsoft Entra Conditional Access policies should enforce MFA for network access"
- "Web Application Firewall should enforce OWASP Top 10 protections on all internet-facing endpoints"

## Output Structure

Your spec output must include all sections from the standard `spec-prompt.md` with these **Network-specific enhancements**:

### 1. Header
- Use the exact best practice statement provided

### 2. Customer Facing Explanation

**Network Pillar Context:**
- Explain how this best practice supports **Zero Trust network principles**: verify explicitly, least-privilege access, and assume breach
- Reference the specific network security objective from the [Zero Trust Network Deployment Guide](https://learn.microsoft.com/en-us/security/zero-trust/deploy/networks):
  - Network segmentation & software-defined perimeters
  - Secure Access Service Edge (SASE) & Zero Trust Network Access (ZTNA)
  - Strong encryption & secure communication
  - Network visibility & threat detection
  - Policy-driven access control & least privilege
  - Cloud and hybrid network security
  - Legacy technology retirement

- Articulate the kill chain showing:
  - **Initial access**: How threat actors bypass weak network controls
  - **Lateral movement**: How inadequate segmentation enables movement across network
  - **Persistence**: How lack of visibility prevents detection
  - **Impact**: Environment-wide exposure if not mitigated

**Data sources for accuracy:**
- Always consult [Zero Trust Network Deployment Guide](https://learn.microsoft.com/en-us/security/zero-trust/deploy/networks)
- Consult specific product documentation at https://learn.microsoft.com/en-us/entra, https://learn.microsoft.com/en-us/azure, etc.
- Use web search to validate current feature availability and API endpoints

### 3. Risk Level, User Impact, Implementation Cost

Use this Network-specific guidance:

**Risk Level:**
- **High**: Network control directly prevents environment-wide exposure (e.g., DDoS protection, segmentation failures allow breach containment failure)
- **Medium**: Control provides defense in depth but doesn't directly prevent initial compromise (e.g., TLS version enforcement, WAF rules)
- **Low**: Control is optimization or hygiene measure (e.g., enabling verbose logging)

**User Impact:**
- **High**: End users cannot access applications until remediated, or widespread notification required
- **Medium**: Some user cohorts affected (e.g., only remote workers, only specific app users)
- **Low**: Administrative action only, users unaffected

**Implementation Cost:**
- **High**: Requires significant infrastructure changes, ongoing resource commitment (e.g., complete network redesign, managed connector deployment)
- **Medium**: Requires project-level effort (e.g., policy rollout, app onboarding to GSA)
- **Low**: Targeted configuration changes (e.g., enable feature flag, add firewall rule)

### 4. Check Query

**Network API Sources:**

This section must include queries to one or more of these API sources:

#### A. Microsoft Entra / Global Secure Access APIs
- **Global Secure Access Private Access**: Resource provisioning, app onboarding, policy configuration
  - Documentation: [Global Secure Access overview](https://learn.microsoft.com/en-us/entra/global-secure-access/overview-what-is-global-secure-access)
  - Related: Private Access, Internet Access, Connector deployment
  
- **Conditional Access Policies**: Network access controls, device compliance, location policies
  - Endpoint: `https://graph.microsoft.com/v1.0/identity/conditionalAccess/policies`
  - Documentation: [Conditional Access policy reference](https://learn.microsoft.com/en-us/entra/identity/conditional-access/reference-conditions)

#### B. Azure Resource Graph & ARM APIs
- **Network Security**: NSGs, Azure Firewall, DDoS Protection, Virtual Networks
  - Endpoints: Azure Resource Manager REST API, Azure Resource Graph
  - Documentation: [Azure Networking documentation](https://learn.microsoft.com/en-us/azure/networking/)

#### C. Microsoft Graph for Identity and Access
- **Network Access Configuration**: Policies, connectors, app provisioning
  - Documentation: [Microsoft Entra Identity documentation](https://learn.microsoft.com/en-us/entra)

**Query Structure:**

For each query, document:

1. **Query Identifier**: `Query n: Qn: [Clear English description]`
2. **API Endpoint**: Complete URL with $filter examples
3. **Documentation Link**: Direct link to https://learn.microsoft.com article supporting this query
4. **What to Check**: Specific property names and expected values for Pass/Fail
5. **Pass Criteria**: Condition that indicates compliance
6. **Fail Criteria**: Condition that indicates non-compliance
7. **Dependencies**: Reference other queries if chained (e.g., Q1, Q2)

**Example Query:**

```
Query 1: Q1: Validate that Global Secure Access Private Access is configured
Endpoint: https://graph.microsoft.com/beta/networkAccess/privateAccess/apps
Documentation: https://learn.microsoft.com/en-us/entra/global-secure-access/how-to-configure-private-access
Property Check: "status" property should be "enabled"
Pass: Private Access configuration exists and status is enabled
Fail: No Private Access configuration found or status is not enabled
```

### 5. Check Results Table

Structure: 3 columns (User-Facing Message | Details | Remediation Resources)

**Column 1 - User-Facing Message:**
- **Pass sentence**: "Pass: [Positive outcome indicating compliance]"
- **Fail sentence**: "Fail: [Negative outcome indicating non-compliance]"
- Both sentences must be understandable to non-technical stakeholders

Example:
- Pass: "Global Secure Access Private Access is enabled for secure remote application access"
- Fail: "Global Secure Access Private Access is not configured, exposing remote access to traditional VPN risks"

**Column 2 - Details:**
- Show query results with relevant properties
- Include resource names, IDs, configuration states
- Link to portal view where applicable (e.g., Global Secure Access admin center, Azure Portal)

**Column 3 - Remediation Resources:**
- List steps to remediate
- Each step should be a sentence followed by a link to https://learn.microsoft.com
- Cover: Where (portal/API), When (urgency), How (steps), Who (required roles)

### 6. Challenges (Internal)

List any checks that cannot be automated because:
- No API available (portal-only configurations)
- API limitations or permissions issues
- Feature in preview with unstable API

For each challenge:
- State what should be checked
- Explain why it cannot be automated
- Provide manual steps in the Azure/Entra admin portals

Example:
```
* Network traffic pattern validation cannot be automated via configuration APIs. 
  To verify traffic patterns match segmentation policy, use Azure Network Watcher Traffic Analytics.
  Navigate to Azure Portal > Network Watcher > Traffic Analytics and review flow logs.
```

## Additional Network Pillar Guidance

### Common API Patterns

**Global Secure Access (GSA):**
- Base endpoint: `https://graph.microsoft.com/beta/networkAccess/` or `/entra/global-secure-access/`
- Check documentation for beta vs. v1.0 availability
- Validate with [Microsoft Graph Explorer](https://developer.microsoft.com/en-us/graph/graph-explorer)

**Azure Networking:**
- Use Azure Resource Manager (ARM) APIs via Azure SDK or REST
- Include subscription ID, resource group name in paths
- Check Azure Portal for feature availability in your region

**Conditional Access:**
- Use stable v1.0 endpoint: `https://graph.microsoft.com/v1.0/identity/conditionalAccess/policies`
- Properties to check: conditions, grantControls, state, displayName

### Validation Checklist

Before finalizing your Network spec, verify:

- [ ] **Accuracy**: All assertions backed by Microsoft Learn documentation
- [ ] **APIs exist**: Tested with Microsoft Graph Explorer or Azure Resource Manager
- [ ] **No speculation**: Never invent endpoints, properties, or features
- [ ] **Current**: APIs are stable (v1.0 or documented beta) and not deprecated
- [ ] **Complete**: All query dependencies documented
- [ ] **Clear criteria**: Pass/Fail conditions are unambiguous
- [ ] **Portal option**: If no API available, documented in Challenges section
- [ ] **Remediation**: Links to Learn docs showing how to fix the issue

### Network Pillar Testing Patterns

Review the [workshop guidance](https://github.com/tdetzner/zerotrustassessment/blob/main/src/react/docs/workshop-guidance/network/) (NET_001.md through NET_092.md) for examples of:
- Global Secure Access and Private Access configurations
- Network access patterns
- Legacy app migration
- Remote access security
- Modern authentication requirements
- Network governance

These provide context for creating specs that align with the broader Zero Trust Assessment program.

## Response Format

Provide the complete spec output as a markdown document following the structure above. Do NOT include explanation text outside the spec sections. The output should be ready to copy directly into a spec file.

Universal Continuous Access Evaluation (Universal CAE) validates network access tokens every time a connection is established through Global Secure Access tunnels. Without Universal CAE, tokens remain valid for 60 to 90 minutes regardless of changes to user state.

Without this protection:

- A threat actor who obtains a token through theft or replay can continue accessing all Global Secure Access-protected resources even after the user's account is disabled or password is reset.
- Critical events like session revocation or high user risk detection don't prompt immediate reauthentication.
- Departing employees or malicious insiders maintain network-level access to private corporate resources for up to 90 minutes after remediation action is taken.
- Token replay attacks from different IP addresses aren't blocked without Strict Enforcement mode.

**Remediation action**
- Review the [Universal CAE](https://learn.microsoft.com/entra/global-secure-access/concept-universal-continuous-access-evaluation?wt.mc_id=zerotrustrecommendations_automation_content_cnl_csasci) capabilities for Global Secure Access.
- Remove or modify Conditional Access policies that disable CAE for Global Secure Access workloads. For more information, see [Continuous access evaluation](https://learn.microsoft.com/entra/identity/conditional-access/concept-continuous-access-evaluation?wt.mc_id=zerotrustrecommendations_automation_content_cnl_csasci).
- Configure Universal CAE to use Strict Enforcement mode for enhanced token replay protection. For more information, see [Universal Continuous Access Evaluation](https://learn.microsoft.com/entra/global-secure-access/concept-universal-continuous-access-evaluation?wt.mc_id=zerotrustrecommendations_automation_content_cnl_csasci#strict-enforcement-mode).
<!--- Results --->
%TestResult%


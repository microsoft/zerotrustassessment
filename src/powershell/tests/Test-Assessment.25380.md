When Global Secure Access routes user traffic through Microsoft's Security Service Edge, it replaces the original source IP with the proxy egress IP. If you don't enable Global Secure Access signaling for Conditional Access, Microsoft Entra ID receives the proxy IP instead of the user's actual IP address. Conditional Access policies that rely on named locations or trusted IP ranges evaluate the proxy IP instead of the user's actual IP, reducing the effectiveness of location-based controls.

If you don't enable Global Secure Access signaling for Conditional Access:

- Microsoft Entra ID Protection risk detections that depend on source IP, such as impossible travel and unfamiliar sign-in properties, are less reliable.
- Sign-in logs record the proxy IP, which prevents security operations teams from correlating sign-in events to user locations during incident response.

**Remediation action**

- [Enable Global Secure Access signaling for Conditional Access](https://learn.microsoft.com/entra/global-secure-access/how-to-source-ip-restoration?wt.mc_id=zerotrustrecommendations_automation_content_cnl_csasci#enable-global-secure-access-signaling-for-conditional-access).
- [Enable compliant network check with Conditional Access](https://learn.microsoft.com/entra/global-secure-access/how-to-compliant-network?wt.mc_id=zerotrustrecommendations_automation_content_cnl_csasci) to require users to connect through Global Secure Access.
- [Understand how Universal Conditional Access works with Global Secure Access traffic profiles](https://learn.microsoft.com/entra/global-secure-access/concept-universal-conditional-access?wt.mc_id=zerotrustrecommendations_automation_content_cnl_csasci).
<!--- Results --->
%TestResult%


When Global Secure Access routes user traffic through Microsoft's Security Service Edge, the original source IP of the user is replaced by the proxy egress IP. If Global Secure Access signaling for Conditional Access is not enabled, Microsoft Entra ID receives the proxy IP instead of the user's IP. Conditional Access policies that rely on named locations or trusted IP ranges evaluate the proxy IP, which does not correspond to the user's location. A threat actor who compromises user credentials can sign in from any location, and the location-based Conditional Access policy will evaluate the proxy IP, not the threat actor's IP, allowing the sign-in to proceed without triggering a location-based block or step-up authentication. In addition, Microsoft Entra ID Protection risk detections that depend on source IP — such as impossible travel, unfamiliar sign-in properties, and anomalous token — operate on the proxy IP, reducing their ability to detect anomalies. Sign-in logs record the proxy IP, which prevents security operations teams from correlating sign-in events to user locations during incident response. Enabling signaling restores the original source IP to Microsoft Entra ID and Microsoft Graph, and allows Conditional Access to enforce compliant network checks, which verify that the user connects through the Global Secure Access tunnel. 

**Remediation actions**

1. [Enable Global Secure Access signaling for Conditional Access in the Microsoft Entra admin center under Global Secure Access > Settings > Session management > Adaptive Access](https://learn.microsoft.com/entra/global-secure-access/how-to-source-ip-restoration)

2. [Understand how Universal Conditional Access works with Global Secure Access traffic profiles](https://learn.microsoft.com/entra/global-secure-access/concept-universal-conditional-access)

3. [Configure compliant network check to require users to connect through Global Secure Access](https://learn.microsoft.com/entra/global-secure-access/how-to-compliant-network)

<!--- Results --->
%TestResult%

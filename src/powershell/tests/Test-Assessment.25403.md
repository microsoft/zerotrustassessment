If you don't deploy Microsoft Entra Private Access sensors to domain controllers, threat actors can exploit Kerberos authentication requests from any device on the network, including unmanaged or compromised endpoints. They can use this vulnerability to get service tickets for on-premises resources without multifactor authentication or device compliance validation.

If you don't deploy Private Access sensors to domain controllers:

- Threat actors can request Kerberos tickets for privileged resources such as file shares, database servers, and remote desktop services. This vulnerability enables lateral movement across the on-premises environment.
- Conditional Access policies don't apply to Kerberos authentication, because it operates within a perimeter-based trust model where any authenticated user can request tickets regardless of authentication strength or device posture.
- Compromised user credentials obtained through phishing or credential theft can be immediately used to access domain-authenticated resources without triggering multifactor authentication requirements.

**Remediation action**

- [Configure Microsoft Entra Private Access for Active Directory domain controllers](https://learn.microsoft.com/entra/global-secure-access/how-to-configure-domain-controllers?wt.mc_id=zerotrustrecommendations_automation_content_cnl_csasci).
<!--- Results --->
%TestResult%


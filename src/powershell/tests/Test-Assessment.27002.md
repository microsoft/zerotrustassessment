TLS inspection uses an intermediate certificate authority to dynamically create leaf certificates for decrypting and inspecting encrypted traffic. When this certificate expires, the service can't perform TLS termination. This expiration immediately disables all TLS inspection capabilities, including URL filtering, threat detection, and data loss prevention on HTTPS traffic. Threat actors know that security controls often lapse during certificate expiration and they time attacks to coincide with these gaps.

If a certificate expires:

- The organization loses visibility into encrypted traffic.
- Threat actors can bypass TLS inspection to deliver encrypted malware, access command-and-control communications, and exfiltrate data.

**Remediation action**

- Maintain a 90-day buffer before certificate expiration to provide time to complete the renewal process. Microsoft recommends that signed certificates remain valid for at least six months.
- Follow the steps in [Configure Transport Layer Security inspection settings](https://learn.microsoft.com/entra/global-secure-access/how-to-transport-layer-security-settings?wt.mc_id=zerotrustrecommendations_automation_content_cnl_csasci) to:
    - Create a new Certificate Signing Request (CSR) and upload a renewed certificate in the Microsoft Entra admin center.
    - Sign the CSR by using your organization's PKI infrastructure with a validity period of at least six months (Microsoft recommendation).
- Use [Active Directory Certificate Services (ADCS)](https://learn.microsoft.com/entra/global-secure-access/scripts/powershell-active-directory-certificate-service?wt.mc_id=zerotrustrecommendations_automation_content_cnl_csasci) or [OpenSSL](https://learn.microsoft.com/entra/global-secure-access/scripts/powershell-open-secure-sockets-layer?wt.mc_id=zerotrustrecommendations_automation_content_cnl_csasci) to sign the CSR.
<!--- Results --->
%TestResult%


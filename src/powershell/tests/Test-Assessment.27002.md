TLS inspection in Global Secure Access relies on an intermediate certificate authority certificate to dynamically generate leaf certificates for decrypting and inspecting encrypted traffic. When this certificate expires, the service can no longer perform TLS termination, which immediately disables all TLS inspection capabilities including URL filtering, threat detection, and data loss prevention on HTTPS traffic. Threat actors are aware that security controls often lapse during certificate expiration windows and may time attacks accordingly, knowing that encrypted malware delivery, command-and-control communications, and data exfiltration will bypass inspection. Organizations that do not proactively monitor certificate expiration risk sudden loss of visibility into encrypted traffic, potentially during a critical security incident. Microsoft documentation recommends that signed certificates remain valid for at least 6 months. Maintaining a 90-day buffer before expiration provides adequate time to complete the certificate renewal process.

**Remediation action**

1. Generate a new Certificate Signing Request (CSR) and upload a renewed certificate in the Microsoft Entra admin center under Global Secure Access > Secure > TLS inspection policies > TLS inspection settings tab
2. Sign the CSR using your organization's PKI infrastructure with a validity period of at least 6 months (Microsoft recommendation)
3. Use Active Directory Certificate Services (AD CS) or OpenSSL to sign the CSR

<!--- Results --->
%TestResult%

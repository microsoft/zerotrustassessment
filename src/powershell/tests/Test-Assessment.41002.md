Microsoft Defender for Identity protects on-premises Active Directory by monitoring authentication and directory traffic at every domain controller. Sensors installed on domain controllers analyze LDAP queries, Kerberos and NTLM authentications, DNS queries, and Active Directory replication traffic to detect identity attacks such as Kerberoasting, Pass-the-Hash, Pass-the-Ticket, DCSync, credential dumping, and lateral movement.

Because every domain controller is authoritative for the full domain, a single unmonitored domain controller creates a blind spot large enough for an attacker to extract credentials for every account in the domain without generating an MDI alert. An outdated, disconnected, or unhealthy sensor produces the same blind spot as a missing one. Sensor coverage must therefore be complete — every domain controller must have a sensor in a healthy, up-to-date, and running state.

**Remediation action**

To install or repair the MDI sensor on a domain controller:
1. Sign in to [Microsoft Defender XDR](https://security.microsoft.com) as a Global Administrator or Security Administrator.
2. Navigate to **Settings > Identities > Sensors**.
3. Download the sensor installer and follow [Install the Microsoft Defender for Identity sensor](https://learn.microsoft.com/en-us/defender-for-identity/deploy/install-sensor).
4. For outdated sensors, see [Update Microsoft Defender for Identity sensors](https://learn.microsoft.com/en-us/defender-for-identity/sensor-settings#update-sensors).
5. For unhealthy sensors, review [Microsoft Defender for Identity health alerts](https://learn.microsoft.com/en-us/defender-for-identity/health-alerts).

- [Plan capacity for Microsoft Defender for Identity](https://learn.microsoft.com/en-us/defender-for-identity/deploy/capacity-planning)
- [Install the Microsoft Defender for Identity sensor](https://learn.microsoft.com/en-us/defender-for-identity/deploy/install-sensor)
- [Configure Microsoft Defender for Identity sensor settings](https://learn.microsoft.com/en-us/defender-for-identity/deploy/configure-sensor-settings)
- [Update Microsoft Defender for Identity sensors](https://learn.microsoft.com/en-us/defender-for-identity/sensor-settings#update-sensors)
- [Microsoft Defender for Identity health alerts](https://learn.microsoft.com/en-us/defender-for-identity/health-alerts)
- [Troubleshoot Microsoft Defender for Identity sensor failures](https://learn.microsoft.com/en-us/defender-for-identity/troubleshooting-known-issues)

<!--- Results --->
%TestResult%

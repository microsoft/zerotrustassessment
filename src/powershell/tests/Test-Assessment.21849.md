When Smart Lockout duration is configured below 60 seconds, threat actors can exploit shortened lockout periods to conduct password spray attacks with reduced detection windows. The default lockout duration is 60 seconds (one minute) and setting it below this threshold creates an opportunity for attackers to perform credential stuffing operations with faster iteration cycles. Threat actors can leverage automated tools to systematically attempt authentication against multiple accounts, and with lockout periods under 60 seconds, they can resume attacks against the same accounts more rapidly. This enables them to maintain persistence in their credential harvesting efforts while potentially evading detection systems that rely on longer observation windows. The compressed timeframe allows attackers to execute more authentication attempts per account over a given period, increasing their probability of success in compromising user credentials through brute force techniques or dictionary attacks.

**Remediation action**
- [Configure Smart Lockout duration](https://learn.microsoft.com/en-us/entra/identity/authentication/howto-password-smart-lockout)

<!--- Results --->
%TestResult%

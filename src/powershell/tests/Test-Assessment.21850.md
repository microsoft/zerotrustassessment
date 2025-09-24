When smart lockout threshold is set to 10 or below, threat actors can exploit this configuration by conducting reconnaissance to identify valid user accounts without triggering lockout protections. Through credential stuffing attacks using compromised credentials from data breaches, attackers can systematically test account credentials while staying below the lockout threshold. This allows threat actors to establish initial access to user accounts without detection. Once initial access is gained, attackers can move laterally through the environment by leveraging the compromised account to access resources and escalate privileges. The persistence mechanism is strengthened because the account remains functional and unlocked, enabling continued access for data exfiltration or deployment of additional tools. A threshold of 10 or below provides insufficient protection against automated password spray attacks that distribute authentication attempts across multiple accounts, making it easier for threat actors to compromise accounts while evading detection mechanisms.

**Remediation action**
* [Configure Smart Lockout duration](https://learn.microsoft.com/en-us/entra/identity/authentication/howto-password-smart-lockout)

<!--- Results --->
%TestResult%

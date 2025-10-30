Without activation alerts for privileged role assignments, threat actors who compromise user credentials through phishing, password attacks, or credential stuffing can activate privileged roles without detection. When privileged roles are activated without notification mechanisms, security teams lack visibility into when elevated permissions are being used, allowing threat actors to operate within the environment undetected during the initial access phase. During the persistence phase, threat actors can leverage activated privileged roles to create backdoors, modify security configurations, or establish additional access methods without triggering security alerts. The lack of activation notifications prevents security teams from correlating privileged role usage with other security events, enabling threat actors to conduct lateral movement and privilege escalation activities while maintaining stealth.

**Remediation action**
- [Configure notifications for privileged roles](https://learn.microsoft.com/en-us/entra/id-governance/privileged-identity-management/pim-how-to-change-default-settings#require-justification-on-active-assignment)
<!--- Results --->
%TestResult%

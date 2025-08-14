Guest accounts with extended sign-in sessions increase the risk surface area that threat actors can exploit. When guest sessions persist beyond necessary timeframes, threat actors often attempt to gain initial access through credential stuffing, password spraying, or social engineering attacks. Once they gain access, they can maintain unauthorized access for extended periods without reauthentication challenges. These compromised and extended sessions:

- Allow unauthorized access to Microsoft Entra artifacts, enabling threat actors to identify sensitive resources and map organizational structures.
- Allow threat actors to persist within the network by using legitimate authentication tokens, making detection more challenging as the activity appears as typical user behavior.
- Provides threat actors with a longer window of time to escalate privileges through techniques like accessing shared resources, discovering more credentials, or exploiting trust relationships between systems.

Without proper session controls, threat actors can achieve lateral movement across the organization's infrastructure, accessing critical data and systems that extend far beyond the original guest account's intended scope of access. 

**Remediation action**
- [Configure adaptive session lifetime policies](https://learn.microsoft.com/en-us/entra/identity/conditional-access/howto-conditional-access-session-lifetime?wt.mc_id=zerotrustrecommendations_automation_content_cnl_csasci) so sign-in frequency policies have shorter live sign-in sessions.<!--- Results --->
%TestResult%


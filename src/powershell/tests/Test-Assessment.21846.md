Guest accounts with extended sign-in sessions to increase risk surface area that threat actors can exploit through multiple attack vectors. When guest sessions persist beyond necessary timeframes, threat actors who gain initial access through credential stuffing, password spraying, or social engineering attacks can maintain unauthorized access for extended periods without re-authentication challenges. Extended sessions increase risk by allowing unauthorized access to Microsoft Entra artifacts, enabling threat actors to perform reconnaissance activities within the environment, identifying sensitive resources and mapping organizational structures. Once established, these compromised sessions allow threat actors to persist within the network by leveraging legitimate authentication tokens, making detection significantly more challenging as the activity appears as normal user behavior. The extended session duration provides threat actors with a longer window of time to escalate privileges through techniques like accessing shared resources, discovering additional credentials, or exploiting trust relationships between systems. Without proper session controls, threat actors can achieve lateral movement across the organization's infrastructure, accessing critical data and systems that extend far beyond the original guest account's intended scope of access. Microsoft recommends guests to sign in once a day or more often.  

**Remediation action**

Reconfigure sign-in frequency policies to have shorter live sign-in sessions. For more information, visit the articles: Configure adaptive session lifetime policies - Microsoft Entra ID | Microsoft Learn 

Common considerations for multitenant user management in Microsoft Entra ID | Azure Docs 

<!--- Results --->
%TestResult%

Without Private DNS configuration, remote users cannot resolve internal domain names through Entra Private Access, forcing them to rely on public DNS servers or manually configure DNS settings. Threat actors can exploit this gap through DNS spoofing attacks, where corrupt DNS data is introduced into resolver caches, causing name servers to return incorrect IP addresses. When users attempt to access internal resources by FQDN without proper DNS resolution through the secure tunnel, threat actors can redirect users from legitimate websites to sites of the attacker's choosing. This enables credential harvesting as users authenticate to what appears to be the correct internal resource but is actually controlled by the threat actor. Through this redirection, threat actors can steal sensitive data from users who believe they are accessing legitimate internal systems. The compromised credentials can then be used to establish persistence within the environment by creating additional access paths or escalating privileges. Without centralized DNS resolution through Private Access, organizations lose visibility into DNS queries and cannot apply consistent security policies, making it harder to detect when threat actors are performing reconnaissance or establishing command and control channels through DNS tunneling. 

**Remediation action**

- [Enable Private DNS and configure DNS suffix segments for internal domains](https://learn.microsoft.com/en-us/entra/global-secure-access/concept-private-name-resolution)

<!--- Results --->
%TestResult%

Prompt Shield in AI Gateway protects enterprise generative AI applications from prompt injection attacks. When organizations allow users to interact with AI applications without this protection, threat actors can exploit prompt injection vulnerabilities through direct attacks (malicious user inputs) or indirect attacks (malicious instructions embedded in external content). Without network-level inspection, these malicious prompts reach the LLM unfiltered, potentially bypassing application-layer safety mechanisms and creating security blind spots.

**Remediation action**

Follow these steps to configure Prompt Shield protection:

1. [Enable the Internet Access traffic forwarding profile](https://learn.microsoft.com/en-us/entra/global-secure-access/how-to-manage-internet-access-profile) to route internet traffic through Global Secure Access
2. [Configure TLS inspection settings](https://learn.microsoft.com/en-us/entra/global-secure-access/how-to-transport-layer-security-settings) and deploy the CA certificate to allow inspection of encrypted AI application traffic
3. [Create prompt policies](https://learn.microsoft.com/en-us/entra/global-secure-access/how-to-ai-prompt-shield#create-a-new-prompt-policy-to-scan-prompts) to scan and block malicious prompts targeting generative AI applications
4. [Link prompt policies to security profiles](https://learn.microsoft.com/en-us/entra/global-secure-access/how-to-ai-prompt-shield#link-the-prompt-policy-to-your-security-profile) to organize them for Conditional Access targeting
5. [Create Conditional Access policies](https://learn.microsoft.com/en-us/entra/global-secure-access/how-to-ai-prompt-shield#create-a-conditional-access-policy) to apply security profiles with prompt policies to users accessing internet resources
6. [Install the Global Secure Access client](https://learn.microsoft.com/en-us/entra/global-secure-access/how-to-install-windows-client) on user devices to enable traffic acquisition

<!--- Results --->
%TestResult%

If organizations don't use Prompt Shield protection, threat actors can exploit prompt injection vulnerabilities to compromise AI-powered workflows. Malicious users can craft adversarial inputs that manipulate large language models into ignoring system instructions, disclosing confidential data, or executing unintended actions like generating phishing content.

Without network-level prompt filtering:

- Direct prompt injection attacks can bypass application-layer safety mechanisms through sophisticated jailbreak techniques.
- Indirect prompt injection occurs when threat actors embed malicious instructions in external content that the AI processes.
- Each AI application must independently implement protection, creating inconsistent security postures and inadequate safeguards against new or custom AI deployments.

**Remediation action**

- [Enable the Internet Access traffic forwarding profile to route internet traffic through Global Secure Access](https://learn.microsoft.com/entra/global-secure-access/how-to-manage-internet-access-profile?wt.mc_id=zerotrustrecommendations_automation_content_cnl_csasci).
- [Configure TLS inspection settings and deploy the CA certificate to allow inspection of encrypted AI application traffic](https://learn.microsoft.com/entra/global-secure-access/how-to-transport-layer-security-settings?wt.mc_id=zerotrustrecommendations_automation_content_cnl_csasci).
- Follow the steps in [Protect enterprise generative AI applications with Prompt Shield](https://learn.microsoft.com/entra/global-secure-access/how-to-ai-prompt-shield?wt.mc_id=zerotrustrecommendations_automation_content_cnl_csasci) to:
    - Create prompt policies to scan and block malicious prompts targeting generative AI applications.
    - Link prompt policies to security profiles to organize them for Conditional Access targeting.
    - Create Conditional Access policies to apply security profiles with prompt policies to users accessing internet resources.
- [Install the Global Secure Access client on user devices to enable traffic acquisition](https://learn.microsoft.com/entra/global-secure-access/how-to-install-windows-client?wt.mc_id=zerotrustrecommendations_automation_content_cnl_csasci).
<!--- Results --->
%TestResult%


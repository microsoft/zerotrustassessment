When high-risk web content filtering categories such as Criminal activity, Hacking, and Illegal software are not blocked, users and devices connected through Global Secure Access remain exposed to dangerous attack vectors and liability risks. Sites categorized as Criminal activity provide guidance on committing illegal acts including fraud, building weapons, and evading detection, and users who access these resources may inadvertently download tools or scripts that threat actors can leverage to establish initial access to the corporate environment. Hacking sites promote unauthorized access techniques, distribute exploit code, and provide tutorials on stealing information and creating malicious software, enabling threat actors who compromise user devices to learn advanced attack methods and escalate their capabilities within the network. Illegal software sites distribute pirated applications, software cracks, and license key generators that frequently contain embedded malware, and users who download from these sources risk executing trojanized installers that establish persistence and enable lateral movement across corporate systems. The absence of blocking for these categories allows users to access content that introduces both security vulnerabilities and legal liability, as downloaded tools may violate software licensing agreements or facilitate unauthorized activities. Organizations that do not enforce blocking of these high-risk Liability categories through their Secure Web Gateway expose themselves to preventable attack vectors while potentially enabling policy violations that create regulatory and legal exposure.


**Remediation action**

1. [Configure web content filtering](https://learn.microsoft.com/en-us/entra/global-secure-access/how-to-configure-web-content-filtering) - Create web content filtering policies that block high-risk Liability categories including Criminal activity, Hacking, and Illegal software.

2. [Web content filtering categories reference](https://learn.microsoft.com/en-us/entra/global-secure-access/reference-web-content-filtering-categories) - Review the complete list of available web categories and their descriptions to understand what content is blocked.

3. [Create security profiles](https://learn.microsoft.com/en-us/entra/global-secure-access/how-to-configure-web-content-filtering#create-a-security-profile) - Group filtering policies into security profiles that can be linked to Conditional Access policies for user-aware enforcement.

4. [Enable Internet Access traffic forwarding](https://learn.microsoft.com/en-us/entra/global-secure-access/how-to-manage-internet-access-profile) - Ensure the Internet Access traffic forwarding profile is enabled to route traffic through Global Secure Access for web content filtering to apply.

5. [Link security profiles to Conditional Access](https://learn.microsoft.com/en-us/entra/global-secure-access/how-to-configure-web-content-filtering#create-and-link-conditional-access-policy) - Associate security profiles with Conditional Access policies to enforce web content filtering for targeted users and groups.

<!--- Results --->
%TestResult%

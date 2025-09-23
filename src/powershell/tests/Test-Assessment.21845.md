# Temporary Access Pass Configuration

## Overview

Without Temporary Access Pass (TAP) enabled, organizations face significant challenges in securely bootstrapping users credentials, creating vulnerability windows where users rely on weaker authentication mechanisms during initial setup. When users cannot register phishing-resistant credentials like FIDO2 security keys or Windows Hello for Business due to lack of existing strong authentication methods, they remain exposed to credential-based attacks including phishing, password spray, or similar attacks. Threat actors can exploit this registration gap by targeting users during their most vulnerable state - when they have limited authentication options available and must rely on traditional username-password combinations. This exposure enables threat actors to compromise user accounts during the critical bootstrapping phase, allowing them to intercept or manipulate the registration process for stronger authentication methods, ultimately gaining persistent access to organizational resources and potentially escalating privileges before security controls are fully established.

**Remediation action**

- [Enable Temporary Access Pass authentication method in the Authentication methods policy](https://learn.microsoft.com/en-us/entra/identity/authentication/howto-authentication-temporary-access-pass#enable-the-temporary-access-pass-policy?wt.mc_id=zerotrustrecommendations_automation_content_cnl_csasci)
- [Create Conditional Access policy for security info registration with authentication strength enforcement](https://learn.microsoft.com/en-us/entra/identity/conditional-access/policy-all-users-security-info-registration?wt.mc_id=zerotrustrecommendations_automation_content_cnl_csasci)
- [Update authentication strength policies to include Temporary Access Pass](https://learn.microsoft.com/en-us/entra/identity/authentication/concept-authentication-strengths?wt.mc_id=zerotrustrecommendations_automation_content_cnl_csasci#create-a-custom-authentication-strength)

<!--- Results --->
%TestResult%

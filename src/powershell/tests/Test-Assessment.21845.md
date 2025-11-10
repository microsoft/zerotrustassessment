Without Temporary Access Pass (TAP) enabled, organizations face significant challenges in securely bootstrapping user credentials, creating a vulnerability where users rely on weaker authentication mechanisms during their initial setup. When users cannot register phishing-resistant credentials like FIDO2 security keys or Windows Hello for Business due to lack of existing strong authentication methods, they remain exposed to credential-based attacks including phishing, password spray, or similar attacks. Threat actors can exploit this registration gap by targeting users during their most vulnerable state, when they have limited authentication options available and must rely on traditional username + password combinations. This exposure enables threat actors to compromise user accounts during the critical bootstrapping phase, allowing them to intercept or manipulate the registration process for stronger authentication methods, ultimately gaining persistent access to organizational resources and potentially escalating privileges before security controls are fully established. 

Enable TAP and use it with security info registration to secure this potential gap in your defenses.

**Remediation action**

- [Learn how to enable Temporary Access Pass in the Authentication methods policy](https://learn.microsoft.com/entra/identity/authentication/howto-authentication-temporary-access-pass?wt.mc_id=zerotrustrecommendations_automation_content_cnl_csasci#enable-the-temporary-access-pass-policy)
- [Learn how to update authentication strength policies to include Temporary Access Pass](https://learn.microsoft.com/entra/identity/authentication/concept-authentication-strength-advanced-options?wt.mc_id=zerotrustrecommendations_automation_content_cnl_csasci)
- [Learn how to create a Conditional Access policy for security info registration with authentication strength enforcement](https://learn.microsoft.com/entra/identity/conditional-access/policy-all-users-security-info-registration?wt.mc_id=zerotrustrecommendations_automation_content_cnl_csasci)
 <!--- Results --->
%TestResult%


If Microsoft Entra Conditional Access policies aren't combined with app protection controls, users can connect to corporate resources through unmanaged or unsecured applications. This exposes sensitive data to risks such as data leakage, unauthorized access, and regulatory noncompliance. Without safeguards like app-level data protection, access restrictions, and data loss prevention, threat actors can exploit unprotected apps to bypass security controls and compromise organizational data.

Enforcing Intune app protection policies within Conditional Access ensures only trusted apps can access corporate data. This supports Zero Trust by enforcing access decisions based on app trust, data containment, and usage restrictions.

**Remediation action**

Configure app-based Conditional Access policies in Microsoft Entra and Intune to require app protection for access to corporate resources:  
- [Set up app-based Conditional Access policies with Intune](https://learn.microsoft.com/intune/intune-service/protect/app-based-conditional-access-intune-create?wt.mc_id=zerotrustrecommendations_automation_content_cnl_csasci)

For more information, see:  
- [What is Conditional Access?](https://learn.microsoft.com/entra/identity/conditional-access/overview?wt.mc_id=zerotrustrecommendations_automation_content_cnl_csasci)
- [Learn about app-based Conditional Access policies with Intune](https://learn.microsoft.com/intune/intune-service/protect/app-based-conditional-access-intune?wt.mc_id=zerotrustrecommendations_automation_content_cnl_csasci)
<!--- Results --->
%TestResult%


If Endpoint Privilege Management (EPM) is not configured and assigned in Intune, standard users who need to perform tasks requiring elevated privileges are forced to operate with full local administrator rights. This creates a broad attack surface: a threat actor who compromises any such account immediately inherits persistent local administrator access across every device where that user is elevated. From there, the attacker can dump credentials from the SAM and LSASS, install persistent backdoors, disable security controls such as Microsoft Defender, and move laterally to other systems using harvested credentials.

EPM disrupts this kill chain by enabling users to run as standard users by default while allowing policy-controlled, just-in-time elevation of specific approved files. This reduces the window of exposure, limits privilege escalation paths, and enforces least privilege across the managed Windows device fleet. EPM also provides audit logging of every elevation action, giving security teams visibility into elevation patterns that may indicate compromise.

Both policy types are required: an **elevation settings policy** enables EPM on the device and sets default elevation behavior, and an **elevation rules policy** defines granular controls over which files can be elevated. Without either, the environment remains reliant on broad local administrator rights.

**Remediation action**

Configure and assign Windows Endpoint Privilege Management policies in Intune:

- [Configure EPM elevation settings policy](https://learn.microsoft.com/intune/intune-service/protect/epm-elevation-settings?wt.mc_id=zerotrustrecommendations_automation_content_cnl_csasci)
- [Configure EPM elevation rules policy](https://learn.microsoft.com/intune/intune-service/protect/epm-elevation-rules?wt.mc_id=zerotrustrecommendations_automation_content_cnl_csasci)

For more information, see:

- [Endpoint Privilege Management overview](https://learn.microsoft.com/intune/intune-service/protect/epm-overview?wt.mc_id=zerotrustrecommendations_automation_content_cnl_csasci)
- [Plan for Endpoint Privilege Management](https://learn.microsoft.com/intune/intune-service/protect/epm-plan?wt.mc_id=zerotrustrecommendations_automation_content_cnl_csasci)
- [Assign device profiles in Intune](https://learn.microsoft.com/mem/intune/configuration/device-profile-assign?wt.mc_id=zerotrustrecommendations_automation_content_cnl_csasci)
<!--- Results --->
%TestResult%

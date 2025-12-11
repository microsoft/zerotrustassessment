Intelligent Local Access (ILA) is a key capability that merges ZTNA policy enforcement with the efficiency of routing Private Access traffic locally—instead of sending all data through the cloud backend, as is typical with standard Private Access. Using ILA is crucial; otherwise, users may turn off Private Access in the GSA client to boost performance, which would bypass all ZTNA policy controls such as user assignment or Entra ID conditional access.

This verification ensures that private networks are set up within the Entra ID tenant. If private networks exist, the check is successful, indicating that Intelligent Local Access is being used.

**Remediation action**

You should consider configuring one or multiple private networks for your user sites and assigning the appropriate applications to it. This will ensure that private access traffic is routed locally when the user is located at these sites to improve performance while maintaining ZTNA policy enforcement.

- [Enable Intelligent Local Network - Global Secure Access](https://learn.microsoft.com/en-us/entra/global-secure-access/enable-intelligent-local-access?wt.mc_id=zerotrustrecommendations_automation_content_cnl_csasci)
<!--- Results --->
%TestResult%

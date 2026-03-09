Global Secure Access deployment logs track the status and progress of configuration changes across the global network. These changes include forwarding profile redistributions, remote network updates, filtering profile changes, and changes to Conditional Access settings. If deployment logs show failed deployments, threat actors can exploit inconsistent security configurations where some edge locations have outdated or misconfigured policies.

If you don't monitor deployment logs:

- Failed deployments can leave security gaps such as outdated forwarding profiles that don't route traffic through security inspection, or filtering profiles that don't block malicious destinations.
- Administrators might remain unaware of outdated configurations, believing that changes are applied uniformly.
- Deployment failures that create exploitable gaps can go undetected.

**Remediation action**

- Follow the steps in [How to use the Global Secure Access deployment logs](https://learn.microsoft.com/entra/global-secure-access/how-to-view-deployment-logs?wt.mc_id=zerotrustrecommendations_automation_content_cnl_csasci) to:
    - Access and review deployment logs in the Microsoft Entra admin center to identify failed deployments.
    - For failed deployments, examine the error message in the `status.message` field and retry the configuration change that triggered the failure.
    - Monitor deployment notifications that appear in the admin center when making configuration changes to catch failures in real-time.
- If deployments consistently fail for remote networks, [review the underlying remote network configuration](https://learn.microsoft.com/entra/global-secure-access/how-to-manage-remote-networks?wt.mc_id=zerotrustrecommendations_automation_content_cnl_csasci) for errors.
- For forwarding profile deployment failures, [verify traffic forwarding configuration](https://learn.microsoft.com/entra/global-secure-access/concept-traffic-forwarding?wt.mc_id=zerotrustrecommendations_automation_content_cnl_csasci).
<!--- Results --->
%TestResult%


Auto-labeling policies can operate in two modes: simulation mode (testing and monitoring) and enforcement mode (active labeling). Organizations that configure auto-labeling policies but leave them in simulation mode indefinitely gain no actual protection or compliance benefits because content is never actually labeled. Simulation mode is a testing mechanism intended to validate policy accuracy before enabling active classification, not a permanent deployment state. When auto-labeling policies remain in simulation mode, sensitive data continues to circulate unclassified, leaving data loss prevention policies unable to detect and protect high-risk content. Users experience no behavior change from the policy's existence, and the organization derives no value from the investment in policy design and configuration. Additionally, simulation mode limits visibility into real-world labeling effectiveness, making it difficult to identify and correct false positive or negative scenarios before enforcement. At least one auto-labeling policy must be active in enforcement mode to ensure that sensitive information is consistently and automatically labeled across Microsoft 365 workloads (Outlook emails, Exchange mailboxes, SharePoint sites, OneDrive accounts, Teams channels, and Power BI). Transitioning policies from simulation to enforcement mode, after validation testing, activates the protective intent of the policy and begins reducing the attack surface by ensuring sensitive content is classified and subject to associated protection rules.

**Remediation action**

To transition auto-labeling policies from simulation to enforcement mode:

1. Access the auto-labeling policies in the Microsoft Purview portal by navigating to Information Protection > Policies > Auto-labeling policies.
   - [Apply sensitivity labels automatically](https://learn.microsoft.com/en-us/purview/apply-sensitivity-label-automatically) provides detailed access instructions.

2. Identify which policies are currently in simulation mode by reviewing the mode column in the policy list. Policies in simulation mode are actively monitoring content but not labeling it, allowing you to validate accuracy before enforcement.

3. Examine the simulation statistics for each policy to validate detection accuracy. Review the past 1-2 weeks of data to confirm the policy correctly identifies sensitive content with acceptable false positive rates. Look at the number of items matched and the confidence levels of the matches.

4. Refine policy conditions if simulation results show excessive false positives or false negatives. Adjust sensitive information type thresholds, add/remove conditions, or modify the label being applied.
   - [Fine-tune sensitive information type detection](https://learn.microsoft.com/en-us/purview/apply-sensitivity-label-automatically) documents condition adjustment steps.

5. Plan the enforcement activation timeline by determining which policies should transition to enforcement first. Prioritize policies targeting high-risk or high-volume data types to maximize early protection impact.

6. Enable enforcement mode on the policy by navigating to the policy details page and selecting the option to enable enforcement (this typically appears as "Turn on enforcement" or "Enable" button). Confirm the action, as switching from simulation to enforcement is a permanent state change.

7. Validate that enforcement is active by checking the policy mode in the list view to confirm it now displays "Enable" instead of "Simulation".
   - [Verify auto-labeling enforcement](https://learn.microsoft.com/en-us/purview/apply-sensitivity-label-automatically) documents verification steps.

8. Monitor enforcement results by regularly reviewing the policy statistics after switching to enforcement mode. Confirm that labeling is occurring as expected and that the label is being applied to the intended content types.

9. Address any enforcement issues by monitoring user reports of incorrect labeling or unexpected labeling patterns. Investigate and adjust policy conditions as needed to improve accuracy in production.

Best practices:
- Test policies in simulation mode for at least 1-2 weeks before switching to enforcement
- Start with policies for your organization's most critical data types (financial data, healthcare records, trade secrets)
- Enable enforcement for one policy at a time to allow monitoring and quick remediation if issues arise
- Combine enforcement policies with DLP rules that use the applied labels for additional protection
- Regularly review enforcement statistics to ensure the policy continues to function correctly
- Communicate policy enforcement activation to relevant stakeholders (finance, legal, IT) who use the labeled data
- Plan for occasional policy refinement as enforcement reveals real-world data patterns not captured in simulationasdv

<!--- Results --->
%TestResult%

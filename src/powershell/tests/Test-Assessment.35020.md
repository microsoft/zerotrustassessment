Auto-labeling policies can operate in two modes: simulation mode (testing and monitoring) and enforcement mode (active labeling). Organizations that configure auto-labeling policies but leave them in simulation mode indefinitely gain no actual protection or compliance benefits because content is never actually labeled. Simulation mode is a testing mechanism intended to validate policy accuracy before enabling active classification, not a permanent deployment state. When auto-labeling policies remain in simulation mode, sensitive data continues to circulate unclassified, leaving data loss prevention policies unable to detect and protect high-risk content. Users experience no behavior change from the policy's existence, and the organization derives no value from the investment in policy design and configuration. Additionally, simulation mode limits visibility into real-world labeling effectiveness, making it difficult to identify and correct false positive or negative scenarios before enforcement. At least one auto-labeling policy must be active in enforcement mode to ensure that sensitive information is consistently and automatically labeled across Microsoft 365 workloads (Outlook emails, Exchange mailboxes, SharePoint sites, OneDrive accounts, Teams channels, and Power BI). Transitioning policies from simulation to enforcement mode, after validation testing, activates the protective intent of the policy and begins reducing the attack surface by ensuring sensitive content is classified and subject to associated protection rules.

**Remediation action**

1. **Access auto-labeling policies**:
   - [Navigate to Auto-labeling policies](https://purview.microsoft.com/informationprotection/autolabeling) in the Microsoft Purview portal.
   - [Apply sensitivity labels automatically](https://learn.microsoft.com/en-us/purview/apply-sensitivity-label-automatically) provides step-by-step access instructions.
2. **Identify policies in simulation mode**:
   - Review the list of auto-labeling policies. Locate policies with Mode: Simulation. These policies are actively monitoring but not labeling content. 
   - [Apply sensitivity labels automatically](https://learn.microsoft.com/en-us/purview/apply-sensitivity-label-automatically) explains simulation mode functionality.
3. **Review simulation statistics**: Before switching to enforcement mode, examine the simulation statistics for the past 1-2 weeks to confirm the policy correctly identifies sensitive content. Look for the number of items matched and verify the match count is reasonable for your organization's data.
4. **Validate accuracy and adjust conditions**: If simulation statistics show excessive false positives or misses, refine the sensitive information type detection rules or conditions in the policy.
   - [Fine-tune sensitive information type detection](https://learn.microsoft.com/en-us/purview/apply-sensitivity-label-automatically) documents condition tuning.
5. **Plan enforcement activation**: Determine which policies should move to enforcement mode first. Prioritize policies for your most sensitive or most common data types (e.g., credit card numbers, customer records) to maximize initial impact.
6. **Switch policy to enforcement mode**: In the policy details page, select the option to enable enforcement or change the mode from "Simulation" to "Enable". Confirm the action as this begins active labeling.
   - [Turn on enforcement for auto-labeling policies](https://learn.microsoft.com/en-us/purview/apply-sensitivity-label-automatically) documents the specific steps.
7. **Monitor enforcement results**: After activating enforcement, regularly review the policy statistics to confirm labeling is occurring as expected. Monitor for unexpected labeling patterns or user reports of incorrectly labeled content. Make additional refinements as needed based on real-world results.

<!--- Results --->
%TestResult%

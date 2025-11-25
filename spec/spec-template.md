<--How to use this template-->

To get started with a new assessment specification:

* Browse to [Test Number Generator](https://github.com/microsoft/zerotrustassessment/issues/627) and claim a new Test ID by commenting under the last comment and claiming the next sequence in the thread.
* Copy this template file to the pillar folder and rename it according to the naming convention: `spec/<pillar>/<TestID>.md`, where `<pillar>` is the relevant pillar (e.g., Identity, Device, Network, Data, Infrastructure) and `<TestID>` is the unique identifier for the assessment.
* Fill out the metadata at the top of the file, replacing the placeholder values with the appropriate information for your assessment.

Delete all `Explanation` blocks in this file (including this one) before submitting the spec for review.

The docs and dev teams will update the status as work progresses.

<--End How to use this template-->

# Title of the test (e.g., Applications don't have certificates with expiration longer than 180 days)

<--Explanation-->

The title should clearly describe the positive outcome we are looking for, so “Green”/”Passed” makes sense.

<--End Explanation-->

## Spec Status

<--Explanation-->

* Draft: The spec is being drafted and is not yet ready for implementation.
* Review: The spec is complete and is under review.
* Approved: The spec has been reviewed and approved for implementation.
* Deprecated: The spec is no longer in use and has been deprecated.

<--End Explanation-->

## Documentation Status

Not started

## Dev Status

Not started

## Minimum License

<--Explanation-->

Comma separated list of service plan names.

See `Service plans included` column in [Product names and service plan](https://learn.microsoft.com/entra/identity/users/licensing-service-plan-reference)

Valid examples:
INTUNE_O365, AAD_PREMIUM_P2, Entra_Premium_Private_Access, Entra_Premium_Internet_Access, AAD_PREMIUM, AAD_WRKLDID_P2

<--End Explanation-->

## Pillar

<--Explanation-->

The relevant pillar(s) for the assessment (e.g., Identity, Device, Network, Data, Infrastructure).

<--End Explanation-->

## SFI Pillar

<--Explanation-->

The specific SFI pillar that the assessment addresses. Choose the most relevant from the following list:

* Accelerate response and remediation
* Monitor and detect cyberthreats
* Protect engineering systems
* Protect identities and secrets
* Protect networks
* Protect tenants and isolate production systems
* Protect tenants and production systems

<--End Explanation-->

## Category

<--Explanation-->

The category of the assessment (e.g., Identity governance).

<--End Explanation-->

## Risk Level

<--Explanation-->

* High: There is environment-wide exposure to threats until issue is mitigated
* Medium: There is a moderate exposure to threats until issue is mitigated
* Low: Mitigation is considered a defense in depth or operational optimizations

<--End Explanation-->

## User Impact

<--Explanation-->

* High: A large number non-privileged users have to take action or be notified of changes
* Medium: A subset of non-privileged users have to take action or be notified of changes
* Low: Action can be taken by administrators, users don’t have to be notified

<--End Explanation-->

## Implementation Cost

<--Explanation-->

* High: Customer IT and Secops teams need to implement programs that require ongoing time or resource commitment of IT Teams.
* Medium: Customer IT and Secops teams need to drive projects
* Low: Customer IT and Secops teams need to execute targeted actions

<--End Explanation-->

## Customer Facing Explanation

<--Explanation-->

TODO: Delete this explanation when writing the spec

Include here an explanation of the check. This will be visible to customers.

Make sure to cover:

* Why is this check important?
* Explain the concept in Entra associated with this check
* What is the security risk if this check does not “Pass”

This section must cover  

* What
* Why
  
<--End Explanation-->

## Check Query

<--Check Query-->

TODO: Delete this explanation when writing the spec

* Data sources and fields used by the check, for developer/implementer clarity. Assume the developer is familiar with Entra APIs (so no need to over-explain)

* What is the interpretation of the data for the check to be considered “Pass”. Consider a test as passed only where there is no ambiguity that this is a positive outcome to customer and avoid false sense of security

* What is the interpretation of the data for the check to be considered “Fail”. Consider a test as failed only when there is no ambiguity that customer is at risk and action must be taken

* If there is ambiguity, mark the test as “Investigate”

<--End Check Query-->

## User facing message

Pass: <--Pass Message: User-facing message when check passes, indicating positive outcome-->

Fail: <--Fail Message: User-facing message when check fails, indicating negative outcome-->

Investigate: <--(If applicable) User-facing message when check is inconclusive, indicating need for further investigation-->

## Test evaluation logic

<--Explanation-->

TODO: Delete this explanation when writing the spec
Describe the logic used to evaluate the test results, including any thresholds or conditions that determine whether the test passes, fails, or requires further investigation.

For example:

* If X > Y, then Pass
* If X < Y, then Fail
* If X is null or cannot be determined, then Investigate
  
<--End Explanation-->

## Test output data

<--Explanation-->

TODO: Delete this explanation when writing the spec
Based on the objects in the query, outline the data shown to the user running the assessment.

If there are multiple values or records returned, describe how they are presented (e.g., in a table, list, etc.) and what key fields or attributes are included.

Include a link to the portal view if applicable. E.g. for Conditional access policies, link to the CA policy portal page.

See the format of existing test results at [https://aka.ms/zerotrust/demo](https://aka.ms/zerotrust/demo)

<--End Explanation-->

## Remediation resources

<--Explanation-->

TODO: Delete this explanation when writing the spec

Outline very high steps to implement remediation, always pointing to our docs. Be sure it covers:

* Where
* When
* How
* Who

<--End Explanation-->

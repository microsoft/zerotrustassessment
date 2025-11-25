---
author.spec: 
author.doc: 
author.dev:
---

<--Explanation-->

To get started with a new assessment specification:

* Browse to [Test Number Generator](https://github.com/microsoft/zerotrustassessment/issues/627) and claim a new Test ID by commenting under the last comment and claiming the next sequence in the thread.
* Copy this template file to the pillar folder and rename it according to the naming convention: `spec/<pillar>/<TestID>.md`, where `<pillar>` is the relevant pillar (e.g., Identity, Device, Network, Data, Infrastructure) and `<TestID>` is the unique identifier for the assessment.
* Set 'author.spec' metadata at the top of the file to the github id of the current user. Leave other author fields blank.
* Delete all `Explanation` blocks in this file (including this one) before submitting the spec for review.
* The docs and dev teams will update the status as work progresses.

<--End Explanation-->

# Title of the test (e.g., Applications don't have certificates with expiration longer than 180 days)
<--Explanation-->

The title should clearly describe the positive outcome we are looking for, so “Green”/”Passed” makes sense.

<--End Explanation-->

## Spec Status

<--Explanation-->

* Not started: (Default) The spec has not yet been started.
* Draft: The spec is being drafted and is not yet ready for implementation.
* Completed: The spec is complete and ready for implementation.

<--End Explanation-->

## Documentation Status

<--Explanation-->

* Not started: (Default) The documentation has not yet been started.
* In Progress: The documentation is being drafted.
* Completed: The documentation is complete.

<--End Explanation-->

## Dev Status

<--Explanation-->

* Not started: (Default) The development has not yet been started.
* In Progress: The development is underway.
* Completed: The development is complete.

<--End Explanation-->

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

One tight paragraph that outlines the risk that this best practice address, and the kill chain that will derive from not following the best practice. Do not use bullet points or numbered list, use a narrative style. You will describe the risk as a kill chain, following the structure of the standard cybersecurity attack frameworks. I want this to be very technical, factual and to the point. Please check for factual accuracy by consulting the entra official documentation using https://learn.microsoft.com. Please refer to attackers or bad actors as "threat actors". Avoid fluff and rely on logical structure and deep customer obsession. Use plain language, but don’t dumb things down. Present facts, not opinions. Do not include hyperbolic language or speculative statements. Stick to articulation of risk. Anticipate counterarguments. Start with the customer and work backwards. Ensure every assertion is backed by data or a clear logical argument. Be frugal with words but exhaustive with clarity.
To create the paragraph, I want you to use your web search tool to research the entra related features are, and then formulate the kill chain based on what you found. If you can't find anything reply saying "I don't know". Do not make stuff up. You have access to an MCP server called `microsoft.docs.mcp` - this tool allows you to search through Microsoft's latest official documentation, and that information might be more detailed or newer than what's in your training data set.

<--End Explanation-->

## Check Query

<--Check Query-->

TODO: Delete this explanation when writing the spec

* Data sources and fields used by the check, for developer/implementer clarity. Assume the developer is familiar with Entra APIs (so no need to over-explain)

* What is the interpretation of the data for the check to be considered “Pass”. Consider a test as passed only where there is no ambiguity that this is a positive outcome to customer and avoid false sense of security

* What is the interpretation of the data for the check to be considered “Fail”. Consider a test as failed only when there is no ambiguity that customer is at risk and action must be taken

* If there is ambiguity, mark the test as “Investigate”
* Use the ms-learn tool to find the relevant articles.
* Use the ms-graph tool to validate the queries.
* A list of steps that document exactly how to check for the best practice in tenants. This list should be very clear for a team of developers to implement this.
* The steps should include one or more queries to Graph or related systems.
* Assign to each query a unique identifier following the convention "Query n", where n is a sequential number. Then also generate a short name of the query using the naming convention "Qn", where n is the same sequential number used in the long name.
* Come up with a description in plain English what to query for.
* Each query should have the specific URL of the rest APIs used (MS Graph, Azure ARM API, etc.). If a check does not have an API, and only can be done using management portals, do not include it in the report, but instead include it in the "Challenges" section below.
* Do NOT include KQL queries. We don't want to use log analytics for this. We want to use only configuration APIs.
* every API endpoint, property, and check must be directly supported by official Microsoft documentation, and that the assistant must cite the exact documentation URL for each. Use the web search tool to find the documentation and ensure you find it. If you cannot find the documentation, call that out.
* reply "I don't know" if it cannot find a documented API or property, never invent endpoints, properties, urls under https://learn.microsoft.com or features.
* summarize the relevant documentation excerpt for each query, showing how it supports the check.
* you must not infer or assume the existence of APIs or properties not explicitly documented.
* always validate the existence of each API and property in the latest Microsoft Learn documentation before including it in the output.
* for each query, also use MS Graph MCP to validate that the query is correct and will return the expected data.
* If you are not able to find an API, call that out in the "Challenges" section below and do not include it in the Check Query section.
* If multiple queries are needed, then call out the dependencies between the queries, using the short name of the query as part of the description
* Also, call out what to look for in the query results to determine if the best practice is a "pass" or a "fail". Call out the exact names of the properties returned by the Query APIs
* Generate each query with the convention "Unique Identifier: Short Identifier: Description", followed by a new line and the details of the query
* Also, cite specific sources coming from https://learn.microsoft.com for accuracy on every query detail. If you cannot find a query, please report "I don't know"
* A subheader called "Check Results"
* Then a table of 3 columns: "User-Facing Message", "Details", "Remediation Resources"
* The first Column will have two sentences. The first sentence will have the prefix "Pass:" and it summarizes that the test passed based on the best practice. The second sentence will have the prefix "Fail:" and it summarizes that the test failed. The sentences should be understandable in the table
* The second column will have data based on the queries above that will help readers to understand the status. This column will contain results from the queries above, with the relevant properties, for readers to understand
* The third column will a list of reference. Each reference will have a sentence that describe the step and then links to https://learn.microsoft.com articles that explain how to remediate. 
* A subheader,called "Challenges (Internal)"
* Include all the checks you find, that cannot be automated. Instead of using the structure of the "Check Query Section", use a single bullet that summarizes what needs to be checked, articulate this cannot be implemented, and call out the steps in the portal on how to do it.

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

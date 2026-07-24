User and Entity Behavior Analytics (UEBA) builds machine-learning behavioral profiles for every user, host, IP address, and application observed in the workspace by analyzing sign-in logs, audit logs, security events, AAD service principal sign-ins, and supported third-party sources. UEBA produces enriched entity pages, anomaly events (BehaviorAnalytics table), and dynamic baselines that downstream analytics rules and Fusion correlate to surface high-fidelity incidents. Without UEBA, Sentinel detection is rule-deterministic — it can match what threat hunters anticipate (a documented IOC, a known TTP) but it cannot detect "this user just did something that user has never done before, from a country that user has never signed in from, against a resource only DA accounts touch". The detection gap is in low-and-slow credential abuse, insider threat, and adversary-in-the-middle session theft, where the threat actor has valid credentials and only a behavioral baseline can flag the deviation. Enabling UEBA also activates IdentityInfo synchronization, which materializes an enriched identity-context table that nearly all modern Sentinel built-in analytics rules join against; without UEBA enabled, a sizeable share of out-of-the-box rules silently produce no results. Enablement is a single workspace-level setting toggled via the Microsoft.SecurityInsights/settings/Ueba resource.

**Remediation action**

- [Enable User and Entity Behavior Analytics (UEBA)](https://learn.microsoft.com/azure/sentinel/enable-entity-behavior-analytics)
- [Identify advanced threats with UEBA](https://learn.microsoft.com/azure/sentinel/identify-threats-with-entity-behavior-analytics)

<!--- Results --->
%TestResult%

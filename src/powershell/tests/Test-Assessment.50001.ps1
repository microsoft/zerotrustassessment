<#
.SYNOPSIS
    Combines all Microsoft Defender for Cloud Secure Score recommendations and MCSB
    compliance assessments into a unified view. Shows every recommendation from either
    source as a unique test result.

.DESCRIPTION
    This test runs two Azure Resource Graph queries:
      1. Secure Score recommendations — per-resource state (Healthy/Unhealthy/NotApplicable),
         secure score control name, description, severity, and remediation.
      2. MCSB compliance assessments (full) — per-resource × per-MCSB-control rows with
         control names, resourceState, and all display fields.

    Recommendations are merged by `recommendationName` (assessment GUID), forming a Venn diagram:

      LEFT ONLY  (secure score only):  emitted with secure score data; no MCSB columns.
      RIGHT ONLY (MCSB only):          emitted with MCSB data; MCSB control columns always present.
      BOTH (intersection):             secure score resources and state are the primary truth;
                                       each resource row is enriched with MCSB control(s) where mapped.

    Category format:
      - Both:               "<secure score control> - <MCSB domain(s)>"
      - Secure score only:  secure score control name
      - MCSB only:          MCSB domain name(s)

    Pass/fail logic:
      - Secure-score-backed results (left-only + both):
          all NotApplicable → Skipped; any Unhealthy → Failed; all Healthy → Passed.
      - MCSB-only results (right-only):
          all notapplicable → Skipped; any unhealthy → Failed; all healthy → Passed.
          (resourceState field, lowercase.)

    Both queries are non-fatal: if one query fails, results from the other are still emitted.
    Only if both return empty are no results emitted.

.NOTES
    Test ID: 50001
    Category: Microsoft Defender for Cloud
    Required API: Azure Resource Graph - SecurityResources
        (microsoft.security/securescores/securescorecontrols
         + microsoft.security/assessments
         + microsoft.security/regulatorycompliancestandards/.../regulatorycomplianceassessments)
#>

function Test-Assessment-50001 {
    [ZtTest(
        Category = 'Microsoft Defender for Cloud',
        MinimumLicense = ('N/A'),
        Pillar = 'Infrastructure',
        RiskLevel = 'High',
        Service = ('Azure'),
        SfiPillar = 'Protect tenants and isolate production systems',
        TenantType = ('Workforce'),
        TestId = 50001,
        Title = 'Microsoft Defender for Cloud Recommendations'
    )]
    [CmdletBinding()]
    param()

    #region Helper Functions
    function Get-McsbCells {
        param(
            [hashtable] $McsbForThisRec,
            [string]    $ResourceId
        )
        $key = if ($ResourceId) { $ResourceId.ToLowerInvariant() } else { '' }
        if ($McsbForThisRec.ContainsKey($key)) {
            $items    = $McsbForThisRec[$key]
            $controls = ($items | Select-Object -ExpandProperty Control     | Sort-Object -Unique) -join ', '
            $names    = ($items | Select-Object -ExpandProperty ControlName | Where-Object { $_ } | Sort-Object -Unique) -join ', '
            return @($controls, $names)
        }
        return @('', '')
    }
    #endregion Helper Functions

    #region Data Collection
    Write-PSFMessage '🟦 Start' -Tag Test -Level VeryVerbose

    $activity = 'Checking Microsoft Defender for Cloud Recommendations'

    Write-ZtProgress -Activity $activity -Status 'Checking Azure connection'

    $azContext = Get-AzContext -ErrorAction SilentlyContinue
    if (-not $azContext) {
        Write-PSFMessage 'Not connected to Azure.' -Level Warning
        Add-ZtTestResultDetail -SkippedBecause NotConnectedAzure
        return
    }

    # KQL 1: Secure Score recommendations (per-resource state + secure score control name)
    $secureScoreQuery = @'
securityresources
| where type == "microsoft.security/securescores/securescorecontrols"
| extend secureScoreName = (extract("/providers/Microsoft.Security/secureScores/([^/]*)/", 1, id))
| where secureScoreName == "ascScore"
| extend environment = (tostring(properties.environment))
| extend scope = (extract("(.*)/providers/Microsoft.Security/secureScores/", 1, id))
| where (environment == "AWS" or environment == "Azure" or environment == "AzureDevOps" or environment == "DockerHub" or environment == "GCP" or environment == "GitHub" or environment == "GitLab" or environment == "JFrog")
| extend controlDisplayName = (tostring(properties.displayName))
| extend controlName = (name)
| extend assessmentKeys = (extract_all("\"id\":\".*?/assessmentMetadata/([^\"]*)\"", tostring(properties.definition.properties.assessmentDefinitions)))
| extend notApplicableResourceCount = (toint(properties.notApplicableResourceCount))
| extend unhealthyResourceCount = (toint(properties.unhealthyResourceCount))
| extend healthyResourceCount = (toint(properties.healthyResourceCount))
| extend controlMaxScore = (toint(properties.score.max))
| extend currentScore = (todouble(properties.score.current))
    | join kind=leftouter (
    securityresources
    | where type == "microsoft.security/securescores"
    | where name == "ascScore"
    | extend environment = (tostring(properties.environment))
    | extend scopeMaxScore = (toint(properties.score.max))
    | extend scopeWeight = (toint(properties.weight))
    | parse id with scope "/providers/Microsoft.Security/secureScores" *
    | where (environment == "AWS" or environment == "Azure" or environment == "AzureDevOps" or environment == "DockerHub" or environment == "GCP" or environment == "GitHub" or environment == "GitLab" or environment == "JFrog")
    | project scope, scopeWeight, scopeMaxScore, joinOn = 1
    | join kind=leftouter (
        securityresources
        | where type == "microsoft.security/securescores"
        | where name == "ascScore"
        | extend environment = (tostring(properties.environment))
        | where (environment == "AWS" or environment == "Azure" or environment == "AzureDevOps" or environment == "DockerHub" or environment == "GCP" or environment == "GitHub" or environment == "GitLab" or environment == "JFrog")
        | extend scopeWeight = (toint(properties.weight))
        | project scopeWeight
        | summarize sumParentScopeWeight = todouble(sum(scopeWeight)), joinOn = 1
    ) on joinOn
    | project-away joinOn, joinOn1
    | project sumParentScopeWeight, scope, scopeWeight = todouble(scopeWeight), scopeMaxScore = todouble(scopeMaxScore)
) on scope
| extend scopeWeight = iff(controlMaxScore == 0, todouble(0), scopeWeight)
| summarize assessmentKeys = any(assessmentKeys),
            controlDisplayName = any(controlDisplayName),
            notApplicableResourceCount = sum(notApplicableResourceCount),
            unhealthyResourceCount = sum(unhealthyResourceCount),
            healthyResourceCount = sum(healthyResourceCount),
            controlMaxScore = max(controlMaxScore),
            sumParentScopeWeight = max(sumParentScopeWeight),
            impactRatio = sum(iff(scopeMaxScore == 0, todouble(0), scopeWeight / scopeMaxScore)),
            controlAggregatedCurrentScoreSum = sum(iff(scopeMaxScore == 0, todouble(0), scopeWeight * currentScore / scopeMaxScore)) by controlName
| extend controlAggregatedMaxScoreSum = impactRatio * controlMaxScore
| extend controlAggregatedCurrentScore = iff(controlAggregatedMaxScoreSum == 0, todouble(0), controlAggregatedCurrentScoreSum / controlAggregatedMaxScoreSum) * controlMaxScore
| extend potentialScoreIncrease = iff(sumParentScopeWeight == 0, todouble(0), (controlAggregatedMaxScoreSum - controlAggregatedCurrentScoreSum) / sumParentScopeWeight) * 100
| project controlsAssessmentsData = pack_all(), controlMaxScore
| extend assessmentKeys = controlsAssessmentsData.assessmentKeys
| extend controlData = pack(
    "controlDisplayName", controlsAssessmentsData.controlDisplayName,
    "controlName", controlsAssessmentsData.controlName,
    "assessmentKeys", controlsAssessmentsData.assessmentKeys,
    "notApplicableResourceCount", controlsAssessmentsData.notApplicableResourceCount,
    "unhealthyResourceCount", controlsAssessmentsData.unhealthyResourceCount,
    "healthyResourceCount", controlsAssessmentsData.healthyResourceCount,
    "totalResourceCount", toint(controlsAssessmentsData.notApplicableResourceCount) + toint(controlsAssessmentsData.unhealthyResourceCount) + toint(controlsAssessmentsData.healthyResourceCount),
    "maxScore", controlsAssessmentsData.controlMaxScore,
    "currentScore", controlsAssessmentsData.controlAggregatedCurrentScore,
    "potentialScoreIncrease", controlsAssessmentsData.potentialScoreIncrease)
| mv-expand assessmentKeys limit 400
| project assessmentKey = tostring(assessmentKeys), controlData
| summarize controlsData = make_set(controlData) by assessmentKey
| join kind=inner (
    securityresources
    | where type == "microsoft.security/assessments"
    | extend assessmentDetails = parse_json(properties)
    | extend resourceDetails = parse_json(assessmentDetails.resourceDetails)
    | extend fullResourceType = tostring(resourceDetails.ResourceType)
    | extend resourceType = tostring(split(fullResourceType, '/')[1])
    | extend exportedTimestamp = now()
    | extend recommendationId = id
    | extend recommendationName = tostring(split(id, '/')[array_length(split(id, '/')) - 1])
    | extend azurePortalRecommendationLink = case(
        tostring(assessmentDetails.links.azurePortal) startswith "https://", tostring(assessmentDetails.links.azurePortal),
        strcat("https://", tostring(assessmentDetails.links.azurePortal))
    )
) on $left.assessmentKey == $right.recommendationName
| project
    exportedTimestamp,
    subscriptionId,
    resourceGroup,
    resourceType,
    resourceName = tostring(resourceDetails.ResourceName),
    displayName = tostring(assessmentDetails.displayName),
    state = tostring(assessmentDetails.status.code),
    severity = tostring(assessmentDetails.metadata.severity),
    remediationSteps = tostring(assessmentDetails.metadata.remediationDescription),
    resourceId = tostring(resourceDetails.ResourceId),
    recommendationName,
    controls = controlsData,
    description = tostring(assessmentDetails.metadata.description),
    recommendationDisplayName = tostring(assessmentDetails.metadata.displayName),
    notApplicableReason = tostring(assessmentDetails.status.cause),
    azurePortalRecommendationLink,
    recommendationId
| join kind=leftouter (
    resourcecontainers
    | where type == "microsoft.resources/subscriptions"
    | project subscriptionId, subscriptionName = name
) on subscriptionId
| project
    subscriptionId,
    subscriptionName,
    resourceGroup,
    resourceType,
    resourceName,
    resourceId,
    recommendationId,
    recommendationName,
    description,
    recommendationDisplayName,
    remediationSteps,
    severity,
    state,
    notApplicableReason,
    controls = coalesce(tostring(parse_json(controls)[0].controlDisplayName), ""),
    azurePortalRecommendationLink
| order by recommendationDisplayName asc
'@

    # KQL 2: MCSB compliance assessments — full query
    # Returns all fields needed to emit standalone test results for MCSB-only recommendations.
    $mcsbQuery = @'
securityresources
| where type == "microsoft.security/regulatorycompliancestandards/regulatorycompliancecontrols/regulatorycomplianceassessments"
| extend scope = properties.scope
| where isempty(scope) or scope in~("Subscription", "MultiCloudAggregation")
| parse id with * "regulatoryComplianceStandards/" complianceStandardId "/regulatoryComplianceControls/" complianceControlId "/regulatoryComplianceAssessments" *
| extend complianceStandardId = replace("-", " ", complianceStandardId)
| where complianceStandardId == "Microsoft cloud security benchmark"
| extend failedResources = toint(properties.failedResources), passedResources = toint(properties.passedResources), skippedResources = toint(properties.skippedResources)
| where failedResources + passedResources + skippedResources > 0 or properties.assessmentType == "MicrosoftManaged"
| join kind = leftouter (
    securityresources
    | where type == "microsoft.security/assessments"
) on subscriptionId, name
| extend complianceState = tostring(properties.state)
| extend resourceSource = tolower(tostring(properties1.resourceDetails.Source))
| extend recommendationId = iff(isnull(id1) or isempty(id1), id, id1)
| extend resourceId = trim(' ', tolower(tostring(case(
    resourceSource =~ "azure", properties1.resourceDetails.Id,
    resourceSource =~ "gcp", properties1.resourceDetails.GcpResourceId,
    resourceSource =~ "aws" and isnotempty(tostring(properties1.resourceDetails.ConnectorId)), properties1.resourceDetails.Id,
    resourceSource =~ "aws", properties1.resourceDetails.AwsResourceId,
    extract("^(.+)/providers/Microsoft.Security/assessments/.+$", 1, recommendationId)
))))
| extend regexResourceId = extract_all(@"/providers/[^/]+(?:/([^/]+)/[^/]+(?:/[^/]+/[^/]+)?)?/([^/]+)/([^/]+)$", resourceId)[0]
| extend resourceType = iff(
    resourceSource =~ "aws" and isnotempty(tostring(properties1.resourceDetails.ConnectorId)), tostring(properties1.additionalData.ResourceType),
    iff(regexResourceId[1] != "", regexResourceId[1], iff(regexResourceId[0] != "", regexResourceId[0], "subscriptions"))
)
| extend resourceName = tostring(regexResourceId[2])
| extend recommendationName = name
| extend recommendationDisplayName = tostring(iff(isnull(properties1.displayName) or isempty(properties1.displayName), properties.description, properties1.displayName))
| extend description = tostring(properties1.metadata.description)
| extend remediationSteps = tostring(properties1.metadata.remediationDescription)
| extend severity = tostring(properties1.metadata.severity)
| extend azurePortalRecommendationLink = tostring(properties1.links.azurePortal)
| mvexpand statusPerInitiative = properties1.statusPerInitiative
| extend expectedInitiative = statusPerInitiative.policyInitiativeName =~ "ASC Default"
| summarize arg_max(toint(expectedInitiative), *) by complianceControlId, recommendationId
| extend expectedInitiativeBool = expectedInitiative == 1
| extend state = iff(expectedInitiativeBool, tolower(statusPerInitiative.assessmentStatus.code), tolower(properties1.status.code))
| extend notApplicableReason = iff(expectedInitiativeBool, tostring(statusPerInitiative.assessmentStatus.cause), tostring(properties1.status.cause))
| join kind = leftouter (
    securityresources
    | where type == "microsoft.security/regulatorycompliancestandards/regulatorycompliancecontrols"
    | parse id with * "regulatoryComplianceStandards/" complianceStandardId "/regulatoryComplianceControls/" *
    | extend complianceStandardId = replace("-", " ", complianceStandardId)
    | where complianceStandardId == "Microsoft cloud security benchmark"
    | where properties.state != "Unsupported"
    | extend controlName = tostring(properties.description)
    | project controlId = name, controlName
    | distinct controlId, controlName
) on $left.complianceControlId == $right.controlId
| extend exportedTimestamp = now()
| join kind=leftouter (
    resourcecontainers
    | where type == "microsoft.resources/subscriptions"
    | extend subscriptionId = tostring(split(id, "/")[2])
    | project subscriptionId, subscriptionName = name
) on subscriptionId
| project
    exportedTimestamp,
    complianceStandard = complianceStandardId,
    complianceControl = complianceControlId,
    complianceControlName = controlName,
    recommendationState = complianceState,
    subscriptionId,
    subscriptionName,
    resourceGroup = resourceGroup1,
    resourceType,
    resourceName,
    resourceId,
    recommendationId,
    recommendationName,
    recommendationDisplayName,
    description,
    remediationSteps,
    severity,
    resourceState = state,
    notApplicableReason,
    azurePortalRecommendationLink
| order by complianceControl asc, recommendationId asc
'@

    Write-ZtProgress -Activity $activity -Status 'Querying Azure Resource Graph for secure score recommendations'
    $secureScoreRecs = @()
    try {
        $secureScoreRecs = @(Invoke-ZtAzureResourceGraphRequest -Query $secureScoreQuery)
        Write-PSFMessage "Secure Score query returned $($secureScoreRecs.Count) records" -Tag Test -Level VeryVerbose
    }
    catch {
        Write-PSFMessage "Secure Score ARG query failed (continuing with MCSB only): $($_.Exception.Message)" -Tag Test -Level Warning
    }

    Write-ZtProgress -Activity $activity -Status 'Querying Azure Resource Graph for MCSB compliance assessments'
    $mcsbRecs = @()
    try {
        $mcsbRecs = @(Invoke-ZtAzureResourceGraphRequest -Query $mcsbQuery)
        Write-PSFMessage "MCSB query returned $($mcsbRecs.Count) records" -Tag Test -Level VeryVerbose
    }
    catch {
        Write-PSFMessage "MCSB ARG query failed (continuing with secure score only): $($_.Exception.Message)" -Tag Test -Level Warning
    }
    #endregion Data Collection

    #region Report Generation
    if ($secureScoreRecs.Count -eq 0 -and $mcsbRecs.Count -eq 0) {
        Write-PSFMessage 'No recommendations found from either query.' -Tag Test -Level Verbose
        Add-ZtTestResultDetail -SkippedBecause NotApplicable -Result 'No Microsoft Defender for Cloud assessments found. Ensure Cloud Security Posture Management and the MCSB compliance standard are enabled on your subscriptions.'
        return
    }

    # MCSB domain map (control ID prefix -> human-readable domain name)
    $mcsbDomainMap = @{
        'NS' = 'Network Security'
        'IM' = 'Identity Management'
        'PA' = 'Privileged Access'
        'DP' = 'Data Protection'
        'AM' = 'Asset Management'
        'LT' = 'Logging and Threat Detection'
        'IR' = 'Incident Response'
        'PV' = 'Posture and Vulnerability Management'
        'ES' = 'Endpoint Security'
        'BR' = 'Backup and Recovery'
        'DS' = 'DevOps Security'
        'GS' = 'Governance and Strategy'
    }

    # Build MCSB enrichment lookups from $mcsbRecs:
    #   $mcsbByRec:        recommendationName -> { resourceId.lower -> [{Control, ControlName}, ...] }
    #   $mcsbDomainsByRec: recommendationName -> HashSet[domain names]
    $mcsbByRec        = @{}
    $mcsbDomainsByRec = @{}
    foreach ($m in $mcsbRecs) {
        if ([string]::IsNullOrWhiteSpace($m.recommendationName)) { continue }
        if (-not $mcsbByRec.ContainsKey($m.recommendationName)) {
            $mcsbByRec[$m.recommendationName]        = @{}
            $mcsbDomainsByRec[$m.recommendationName] = [System.Collections.Generic.HashSet[string]]::new([System.StringComparer]::OrdinalIgnoreCase)
        }
        $resKey = if ($m.resourceId) { $m.resourceId.ToLowerInvariant() } else { '' }
        if (-not $mcsbByRec[$m.recommendationName].ContainsKey($resKey)) {
            $mcsbByRec[$m.recommendationName][$resKey] = [System.Collections.Generic.List[object]]::new()
        }
        $null = $mcsbByRec[$m.recommendationName][$resKey].Add([PSCustomObject]@{
            Control     = $m.complianceControl
            ControlName = $m.complianceControlName
        })
        if (-not [string]::IsNullOrWhiteSpace($m.complianceControl)) {
            $prefix     = ($m.complianceControl -split '\.')[0].ToUpper()
            $domainName = if ($mcsbDomainMap.ContainsKey($prefix)) { $mcsbDomainMap[$prefix] } else { $m.complianceControl }
            $null = $mcsbDomainsByRec[$m.recommendationName].Add($domainName)
        }
    }

    # Build per-recommendation group hashes for O(1) lookup
    $secureScoreGroupHash = $secureScoreRecs | Group-Object -Property recommendationName -AsHashTable -AsString
    $mcsbGroupHash        = $mcsbRecs        | Group-Object -Property recommendationName -AsHashTable -AsString
    if (-not $secureScoreGroupHash) { $secureScoreGroupHash = @{} }
    if (-not $mcsbGroupHash)        { $mcsbGroupHash        = @{} }

    # Build a sorted union of all recommendation names (SecureScore first to get display names, then MCSB-only)
    $allRecsSorted = @(
        $secureScoreGroupHash.Keys | ForEach-Object {
            [PSCustomObject]@{ Name = $_; DisplayName = $secureScoreGroupHash[$_][0].recommendationDisplayName }
        }
        $mcsbGroupHash.Keys | Where-Object { -not $secureScoreGroupHash.ContainsKey($_) } | ForEach-Object {
            [PSCustomObject]@{ Name = $_; DisplayName = $mcsbGroupHash[$_][0].recommendationDisplayName }
        }
    ) | Sort-Object DisplayName

    # Pre-register all recommendations as Running/Queued so the progress dashboard shows
    # them all immediately. Each flips to Done as its report block completes.
    foreach ($rec in $allRecsSorted) {
        Update-ZtProgressState -WorkerId $rec.Name -WorkerName $rec.DisplayName -WorkerStatus 'Running' -WorkerDetail 'Queued'
    }

    foreach ($rec in $allRecsSorted) {
        $recName = $rec.Name
        $inSS    = $secureScoreGroupHash.ContainsKey($recName)

        # ── SECURE SCORE BACKED (left-only or both intersection) ─────────────────────
        if ($inSS) {
            $rows     = $secureScoreGroupHash[$recName]
            $firstRow = $rows[0]
            $testId   = $recName
            $title    = $firstRow.recommendationDisplayName
            $risk     = switch ($firstRow.severity) {
                            'Critical' { 'High' }  # New classification added by Microsoft on March 2025
                            'High'   { 'High' }
                            'Medium' { 'Medium' }
                            'Low'    { 'Low' }
                            default  { 'Medium' }  # Treat None/Informational as Medium
                        }

            # MCSB enrichment lookup — populated when this rec also appears in MCSB
            $mcsbForThisRec = if ($mcsbByRec.ContainsKey($recName)) { $mcsbByRec[$recName] } else { @{} }
            $showMcsb       = $mcsbForThisRec.Count -gt 0

            # Category: "secure score control - MCSB domain(s)" when both exist
            $secureScoreCategory = $firstRow.controls
            $mcsbDomainList      = $null
            if ($mcsbDomainsByRec.ContainsKey($recName) -and $mcsbDomainsByRec[$recName].Count -gt 0) {
                $mcsbDomainList = ($mcsbDomainsByRec[$recName] | Sort-Object) -join ', '
            }
            $category = if (-not [string]::IsNullOrWhiteSpace($secureScoreCategory) -and $mcsbDomainList) {
                "$secureScoreCategory - $mcsbDomainList"
            }
            elseif (-not [string]::IsNullOrWhiteSpace($secureScoreCategory)) {
                $secureScoreCategory
            }
            elseif ($mcsbDomainList) {
                $mcsbDomainList
            }
            else {
                'Microsoft Defender for Cloud'
            }

            # Description + optional remediation section
            $descriptionText = ConvertTo-ZtMarkdown $firstRow.description

            $remediationSection = ''
            if (-not [string]::IsNullOrWhiteSpace($firstRow.remediationSteps)) {
                $cleanRemediation = ConvertTo-ZtMarkdown $firstRow.remediationSteps
                if (-not [string]::IsNullOrWhiteSpace($cleanRemediation)) {
                    $remediationSection = @"

**Remediation action**

$cleanRemediation
"@
                }
            }

            $descriptionMd = @"
$descriptionText
$remediationSection
"@

            # State separation (secure score: title-case)
            $applicableRows    = @($rows | Where-Object { $_.state -ne 'NotApplicable' })
            $notApplicableRows = @($rows | Where-Object { $_.state -eq 'NotApplicable' })

            # Column presence flags — single pass, short-circuits once all three are found
            $showResourceGroup = $false; $showResourceType = $false; $showResource = $false
            foreach ($r in $rows) {
                if (-not $showResourceGroup -and -not [string]::IsNullOrWhiteSpace($r.resourceGroup)) { $showResourceGroup = $true }
                if (-not $showResourceType  -and -not [string]::IsNullOrWhiteSpace($r.resourceType))  { $showResourceType  = $true }
                if (-not $showResource      -and -not [string]::IsNullOrWhiteSpace($r.resourceName))  { $showResource      = $true }
                if ($showResourceGroup -and $showResourceType -and $showResource) { break }
            }

            # Dynamic table header
            $tableHeader = '|'
            $tableSep    = '|'
            $tableHeader += ' Subscription |';      $tableSep += ' :----------- |'
            if ($showResourceGroup) { $tableHeader += ' Resource group |';    $tableSep += ' :------------- |' }
            if ($showResourceType)  { $tableHeader += ' Resource type |';     $tableSep += ' :------------ |' }
            if ($showMcsb)          { $tableHeader += ' MCSB control |';      $tableSep += ' :----------- |'
                                      $tableHeader += ' MCSB control name |'; $tableSep += ' :---------------- |' }
            if ($showResource)      { $tableHeader += ' Affected resource |'; $tableSep += ' :---------------- |' }
            $tableHeader += ' Status |';            $tableSep += ' :----- |'
            $tableHeader += ' Azure portal |';      $tableSep += ' :----------- |'
            $tableHeaderMd = "$tableHeader`n$tableSep"

            # All-NotApplicable path
            if ($applicableRows.Count -eq 0) {
                $naReasons = ($notApplicableRows | ForEach-Object { $_.notApplicableReason } | Where-Object { $_ } | Select-Object -Unique) -join ', '

                $naTableRows = @(foreach ($row in $notApplicableRows | Sort-Object subscriptionName, resourceGroup, resourceName) {
                    $subLink      = "https://portal.azure.com/#resource/subscriptions/$($row.subscriptionId)"
                    $subMd        = "[$(Get-SafeMarkdown $row.subscriptionName)]($subLink)"
                    $resLink      = "https://portal.azure.com/#resource$($row.resourceId)"
                    $resMd        = "[$(Get-SafeMarkdown $row.resourceName)]($resLink)"
                    $portalLinkMd = if (-not [string]::IsNullOrWhiteSpace($row.azurePortalRecommendationLink)) { "[View recommendation]($($row.azurePortalRecommendationLink))" } else { '' }
                    $mcsbCells    = Get-McsbCells -McsbForThisRec $mcsbForThisRec -ResourceId $row.resourceId

                    $rowMd = '|'
                    $rowMd += " $subMd |"
                    if ($showResourceGroup) { $rowMd += " $($row.resourceGroup) |" }
                    if ($showResourceType)  { $rowMd += " $($row.resourceType) |" }
                    if ($showMcsb)          { $rowMd += " $($mcsbCells[0]) |"; $rowMd += " $($mcsbCells[1]) |" }
                    if ($showResource)      { $rowMd += " $resMd |" }
                    $rowMd += ' N/A |'
                    $rowMd += " $portalLinkMd |"
                    "$rowMd`n"
                }) -join ''

                $naResultMd = @"
$naReasons

$tableHeaderMd
$naTableRows
"@

                $params = @{
                    TestId         = $testId
                    Title          = $title
                    Description    = $descriptionMd
                    SkippedBecause = 'NotApplicable'
                    Result         = $naResultMd
                    Pillar         = 'Infrastructure'
                    Category       = $category
                    Risk           = $risk
                }
                Add-ZtTestResultDetail @params
                Update-ZtProgressState -WorkerId $testId -WorkerName $title -WorkerStatus 'Done'
                continue
            }

            # Pass/fail: any Unhealthy → Failed; otherwise Passed
            $hasUnhealthy = @($applicableRows | Where-Object { $_.state -eq 'Unhealthy' }).Count -gt 0
            $passed       = -not $hasUnhealthy

            # Result table
            $tableRows = @(foreach ($row in $rows | Sort-Object subscriptionName, resourceGroup, resourceName) {
                $subLink      = "https://portal.azure.com/#resource/subscriptions/$($row.subscriptionId)"
                $subMd        = "[$(Get-SafeMarkdown $row.subscriptionName)]($subLink)"
                $resLink      = "https://portal.azure.com/#resource$($row.resourceId)"
                $resMd        = "[$(Get-SafeMarkdown $row.resourceName)]($resLink)"
                $stateIcon    = switch ($row.state) {
                    'Healthy'   { '✅' }
                    'Unhealthy' { '❌' }
                    default     { 'N/A' }
                }
                $portalLinkMd = if (-not [string]::IsNullOrWhiteSpace($row.azurePortalRecommendationLink)) { "[View recommendation]($($row.azurePortalRecommendationLink))" } else { '' }
                $mcsbCells    = Get-McsbCells -McsbForThisRec $mcsbForThisRec -ResourceId $row.resourceId

                $rowMd = '|'
                $rowMd += " $subMd |"
                if ($showResourceGroup) { $rowMd += " $($row.resourceGroup) |" }
                if ($showResourceType)  { $rowMd += " $($row.resourceType) |" }
                if ($showMcsb)          { $rowMd += " $($mcsbCells[0]) |"; $rowMd += " $($mcsbCells[1]) |" }
                if ($showResource)      { $rowMd += " $resMd |" }
                $rowMd += " $stateIcon |"
                $rowMd += " $portalLinkMd |"
                "$rowMd`n"
            }) -join ''

            $resultMd = @"
$title

$tableHeaderMd
$tableRows
"@

            $params = @{
                TestId      = $testId
                Title       = $title
                Status      = $passed
                Result      = $resultMd
                Description = $descriptionMd
                Risk        = $risk
                Pillar      = 'Infrastructure'
                Category    = $category
            }
            Add-ZtTestResultDetail @params
            Update-ZtProgressState -WorkerId $testId -WorkerName $title -WorkerStatus 'Done'
        }

        # ── MCSB ONLY (right-only) ────────────────────────────────────────────────────
        else {
            $rows     = $mcsbGroupHash[$recName]
            $firstRow = $rows[0]
            $testId   = $recName
            $title    = if (-not [string]::IsNullOrWhiteSpace($firstRow.recommendationDisplayName)) { $firstRow.recommendationDisplayName } else { $recName }
            $risk     = switch ($firstRow.severity) {
                            'Critical' { 'High' }  # New classification added by Microsoft on March 2025
                            'High'   { 'High' }
                            'Medium' { 'Medium' }
                            'Low'    { 'Low' }
                            default  { 'Medium' }  # Treat None/Informational as Medium
                        }

            # Category: MCSB domain name(s)
            $mcsbDomainList = $null
            if ($mcsbDomainsByRec.ContainsKey($recName) -and $mcsbDomainsByRec[$recName].Count -gt 0) {
                $mcsbDomainList = ($mcsbDomainsByRec[$recName] | Sort-Object) -join ', '
            }
            $category = if ($mcsbDomainList) { $mcsbDomainList } else { 'Microsoft cloud security benchmark' }

            # Description + optional remediation section
            $descriptionText = ConvertTo-ZtMarkdown $firstRow.description

            $remediationSection = ''
            if (-not [string]::IsNullOrWhiteSpace($firstRow.remediationSteps)) {
                $cleanRemediation = ConvertTo-ZtMarkdown $firstRow.remediationSteps
                if (-not [string]::IsNullOrWhiteSpace($cleanRemediation)) {
                    $remediationSection = @"

**Remediation action**

$cleanRemediation
"@
                }
            }

            $descriptionMd = @"
$descriptionText
$remediationSection
"@

            # State separation (MCSB resourceState is lowercase)
            $applicableRows    = @($rows | Where-Object { $_.resourceState -ne 'notapplicable' })
            $notApplicableRows = @($rows | Where-Object { $_.resourceState -eq 'notapplicable' })

            # Column presence flags — single pass, short-circuits once all three are found
            $showResourceGroup = $false; $showResourceType = $false; $showResource = $false
            foreach ($r in $rows) {
                if (-not $showResourceGroup -and -not [string]::IsNullOrWhiteSpace($r.resourceGroup)) { $showResourceGroup = $true }
                if (-not $showResourceType  -and -not [string]::IsNullOrWhiteSpace($r.resourceType))  { $showResourceType  = $true }
                if (-not $showResource      -and -not [string]::IsNullOrWhiteSpace($r.resourceName))  { $showResource      = $true }
                if ($showResourceGroup -and $showResourceType -and $showResource) { break }
            }

            # Dynamic table header — MCSB control columns are always present for MCSB-only recs
            $tableHeader = '|'
            $tableSep    = '|'
            $tableHeader += ' Subscription |'; $tableSep += ' :----------- |'
            if ($showResourceGroup) { $tableHeader += ' Resource group |'; $tableSep += ' :------------- |' }
            if ($showResourceType)  { $tableHeader += ' Resource type |';  $tableSep += ' :------------ |' }
            $tableHeader += ' MCSB control |';      $tableSep += ' :----------- |'
            $tableHeader += ' MCSB control name |'; $tableSep += ' :---------------- |'
            if ($showResource)      { $tableHeader += ' Affected resource |'; $tableSep += ' :---------------- |' }
            $tableHeader += ' Status |';  $tableSep += ' :----- |'
            $tableHeader += ' Azure portal |'; $tableSep += ' :----------- |'
            $tableHeaderMd = "$tableHeader`n$tableSep"

            # All-NotApplicable path
            if ($applicableRows.Count -eq 0) {
                $naReasons = ($notApplicableRows | ForEach-Object { $_.notApplicableReason } | Where-Object { $_ } | Select-Object -Unique) -join ', '

                $naTableRows = @(foreach ($row in $notApplicableRows | Sort-Object subscriptionName, complianceControl, resourceGroup, resourceName) {
                    $subLink      = "https://portal.azure.com/#resource/subscriptions/$($row.subscriptionId)"
                    $subMd        = "[$(Get-SafeMarkdown $row.subscriptionName)]($subLink)"
                    $resLink      = "https://portal.azure.com/#resource$($row.resourceId)"
                    $resMd        = "[$(Get-SafeMarkdown $row.resourceName)]($resLink)"
                    $portalLinkMd = if (-not [string]::IsNullOrWhiteSpace($row.azurePortalRecommendationLink)) { "[View recommendation]($($row.azurePortalRecommendationLink))" } else { '' }

                    $rowMd = '|'
                    $rowMd += " $subMd |"
                    if ($showResourceGroup) { $rowMd += " $($row.resourceGroup) |" }
                    if ($showResourceType)  { $rowMd += " $($row.resourceType) |" }
                    $rowMd += " $($row.complianceControl) |"
                    $rowMd += " $($row.complianceControlName) |"
                    if ($showResource)      { $rowMd += " $resMd |" }
                    $rowMd += ' N/A |'
                    $rowMd += " $portalLinkMd |"
                    "$rowMd`n"
                }) -join ''

                $naResultMd = @"
$naReasons

$tableHeaderMd
$naTableRows
"@

                $params = @{
                    TestId         = $testId
                    Title          = $title
                    Description    = $descriptionMd
                    SkippedBecause = 'NotApplicable'
                    Result         = $naResultMd
                    Pillar         = 'Infrastructure'
                    Category       = $category
                    Risk           = $risk
                }
                Add-ZtTestResultDetail @params
                Update-ZtProgressState -WorkerId $testId -WorkerName $title -WorkerStatus 'Done'
                continue
            }

            # Pass/fail: any unhealthy → Failed; otherwise Passed
            $hasUnhealthy = @($applicableRows | Where-Object { $_.resourceState -eq 'unhealthy' }).Count -gt 0
            $passed       = -not $hasUnhealthy

            # Result table
            $tableRows = @(foreach ($row in $rows | Sort-Object subscriptionName, complianceControl, resourceGroup, resourceName) {
                $subLink      = "https://portal.azure.com/#resource/subscriptions/$($row.subscriptionId)"
                $subMd        = "[$(Get-SafeMarkdown $row.subscriptionName)]($subLink)"
                $resLink      = "https://portal.azure.com/#resource$($row.resourceId)"
                $resMd        = "[$(Get-SafeMarkdown $row.resourceName)]($resLink)"
                $stateIcon    = switch ($row.resourceState) {
                    'healthy'   { '✅' }
                    'unhealthy' { '❌' }
                    default     { 'N/A' }
                }
                $portalLinkMd = if (-not [string]::IsNullOrWhiteSpace($row.azurePortalRecommendationLink)) { "[View recommendation]($($row.azurePortalRecommendationLink))" } else { '' }

                $rowMd = '|'
                $rowMd += " $subMd |"
                if ($showResourceGroup) { $rowMd += " $($row.resourceGroup) |" }
                if ($showResourceType)  { $rowMd += " $($row.resourceType) |" }
                $rowMd += " $($row.complianceControl) |"
                $rowMd += " $($row.complianceControlName) |"
                if ($showResource)      { $rowMd += " $resMd |" }
                $rowMd += " $stateIcon |"
                $rowMd += " $portalLinkMd |"
                "$rowMd`n"
            }) -join ''

            $resultMd = @"
$title

$tableHeaderMd
$tableRows
"@

            $params = @{
                TestId      = $testId
                Title       = $title
                Status      = $passed
                Result      = $resultMd
                Description = $descriptionMd
                Risk        = $risk
                Pillar      = 'Infrastructure'
                Category    = $category
            }
            Add-ZtTestResultDetail @params
            Update-ZtProgressState -WorkerId $testId -WorkerName $title -WorkerStatus 'Done'
        }
    }
    #endregion Report Generation

    $bothCount     = @($secureScoreGroupHash.Keys | Where-Object { $mcsbGroupHash.ContainsKey($_) }).Count
    $secureScoreOnlyCount   = $secureScoreGroupHash.Count - $bothCount
    $mcsbOnlyCount = $mcsbGroupHash.Count - $bothCount
    Write-PSFMessage "Emitted $($allRecsSorted.Count) test results: $secureScoreOnlyCount secure-score-only, $mcsbOnlyCount MCSB-only, $bothCount merged (both)" -Tag Test -Level VeryVerbose
}

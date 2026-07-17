Describe 'Export-TenantData Graph query allowlists' {
	BeforeAll {
		$srcRoot = Join-Path $PSScriptRoot '../../src/powershell'
		if (-not (Get-Module ZeroTrustAssessment -ErrorAction SilentlyContinue)) {
			Import-Module (Join-Path $srcRoot 'ZeroTrustAssessment.psd1') -Global 3>$null
			Import-Module (Join-Path $srcRoot 'ZeroTrustAssessment.psm1') -Global -Force 3>$null
		}
		function global:Export-GraphEntity {
			param ($ExportPath, $EntityName, $EntityUri, $ProgressActivity, $QueryString, $RelatedPropertyNames, [switch] $ShowCount, $MaximumQueryTime)
		}
		function global:Export-GraphEntityPrivilegedGroup {
			param ($ExportPath, $ProgressActivity, $InputEntityName, $EntityName)
		}

		$script:userBaseQuery = '$top=999&$select=id,displayName,userPrincipalName,accountEnabled,userType,passwordPolicies,createdDateTime,onPremisesSyncEnabled,externalUserState'
		$script:applicationQuery = '$top=999&$select=id,appId,displayName,signInAudience,passwordCredentials,keyCredentials,servicePrincipalLockConfiguration,tags,customSecurityAttributes'
		$script:servicePrincipalQuery = '$expand=appRoleAssignments&$top=999&$select=id,appId,displayName,appOwnerOrganizationId,publisherName,signInAudience,passwordCredentials,keyCredentials,servicePrincipalType,accountEnabled,tags,customSecurityAttributes,agentIdentityBlueprintId,createdByAppId,preferredSingleSignOnMode,appRoleAssignmentRequired,appRoles,replyUrls'
		$script:signInSelect = '$select=createdDateTime,deviceDetail,conditionalAccessStatus,authenticationRequirement,isInteractive,status'
	}

	AfterAll {
		Remove-Item Function:\Export-GraphEntity, Function:\Export-GraphEntityPrivilegedGroup -ErrorAction SilentlyContinue
	}

	It 'uses the focused allowlists in export-tenant.config.psd1' {
		$configPath = Join-Path $srcRoot 'assets/export-tenant.config.psd1'
		$config = @([scriptblock]::Create((Get-Content $configPath -Raw)).Invoke())

		$users = @($config | Where-Object Name -eq 'User')
		$users.Count | Should -Be 2
		($users | Where-Object ExcludePlan -contains 'Free').QueryString | Should -Be "$script:userBaseQuery,signInActivity"
		($users | Where-Object IncludePlan -contains 'Free').QueryString | Should -Be $script:userBaseQuery
		$users.QueryString | Should -Not -Match 'assignedPlans|assignedLicenses'

		($config | Where-Object Name -eq 'Application').QueryString | Should -Be $script:applicationQuery
		$servicePrincipal = $config | Where-Object Name -eq 'ServicePrincipal'
		$servicePrincipal.QueryString | Should -Be $script:servicePrincipalQuery
		$servicePrincipal.RelatedPropertyNames | Should -Be @('oauth2PermissionGrants', 'owners')
		($config | Where-Object Name -eq 'SignIn').QueryString | Should -Be "%AuditQueryString%&$script:signInSelect"
		($config | Where-Object Name -eq 'RoleAssignment').QueryString | Should -Be '$expand=principal($select=id,displayName,userPrincipalName)'
		($config | Where-Object Name -eq 'RoleAssignmentScheduleInstance').QueryString | Should -Be '$expand=principal($select=id,displayName,userPrincipalName)&$filter = assignmentType eq ''Assigned'''
		($config | Where-Object Name -eq 'RoleEligibilityScheduleInstance').QueryString | Should -Be '$expand=principal($select=id,displayName,userPrincipalName)'
	}

	It 'uses the focused allowlists in the hardcoded export path' {
		Mock -ModuleName ZeroTrustAssessment Get-ZtLicenseInformation { 'P2' }
		Mock -ModuleName ZeroTrustAssessment Get-MgContext { @{ Environment = 'Global' } }
		Mock -ModuleName ZeroTrustAssessment Export-GraphEntity {}
		Mock -ModuleName ZeroTrustAssessment Export-GraphEntityPrivilegedGroup {}

		Export-TenantData -ExportPath $TestDrive -Days 7 -MaximumSignInLogQueryTime 1 -Pillar Identity

		Should -Invoke -ModuleName ZeroTrustAssessment Export-GraphEntity -Times 1 -Exactly -ParameterFilter {
			$EntityName -eq 'User' -and $QueryString -eq "$script:userBaseQuery,signInActivity" -and
			$QueryString -notmatch 'assignedPlans|assignedLicenses'
		}
		Should -Invoke -ModuleName ZeroTrustAssessment Export-GraphEntity -Times 1 -Exactly -ParameterFilter {
			$EntityName -eq 'Application' -and $QueryString -eq $script:applicationQuery
		}
		Should -Invoke -ModuleName ZeroTrustAssessment Export-GraphEntity -Times 1 -Exactly -ParameterFilter {
			$EntityName -eq 'ServicePrincipal' -and $QueryString -eq $script:servicePrincipalQuery -and
			(@($RelatedPropertyNames) -join ',') -eq 'oauth2PermissionGrants,owners'
		}
		Should -Invoke -ModuleName ZeroTrustAssessment Export-GraphEntity -Times 1 -Exactly -ParameterFilter {
			$EntityName -eq 'SignIn' -and $QueryString -match '^createdDateTime ge .* and status/errorcode eq 0 and appid eq ''89bee1f7-5e6e-4d8a-9f3d-ecd601259da7''&' -and
			$QueryString.EndsWith($script:signInSelect)
		}
		Should -Invoke -ModuleName ZeroTrustAssessment Export-GraphEntity -Times 1 -Exactly -ParameterFilter {
			$EntityName -eq 'RoleAssignment' -and $QueryString -eq '$expand=principal($select=id,displayName,userPrincipalName)'
		}
		Should -Invoke -ModuleName ZeroTrustAssessment Export-GraphEntity -Times 1 -Exactly -ParameterFilter {
			$EntityName -eq 'RoleAssignmentScheduleInstance' -and $QueryString -eq '$expand=principal($select=id,displayName,userPrincipalName)&$filter = assignmentType eq ''Assigned'''
		}
		Should -Invoke -ModuleName ZeroTrustAssessment Export-GraphEntity -Times 1 -Exactly -ParameterFilter {
			$EntityName -eq 'RoleEligibilityScheduleInstance' -and $QueryString -eq '$expand=principal($select=id,displayName,userPrincipalName)'
		}
	}

	It 'keeps empty-export schema models aligned with the focused allowlists' {
		$modelRoot = Join-Path $srcRoot 'assets/export-model'
		$user = (Get-Content (Join-Path $modelRoot 'User-model.json') -Raw | ConvertFrom-Json).value[0]
		$application = (Get-Content (Join-Path $modelRoot 'Application-model.json') -Raw | ConvertFrom-Json).value[0]
		$servicePrincipal = (Get-Content (Join-Path $modelRoot 'ServicePrincipal-model.json') -Raw | ConvertFrom-Json).value[0]
		$signIn = (Get-Content (Join-Path $modelRoot 'SignIn-model.json') -Raw | ConvertFrom-Json).value[0]
		$servicePrincipalSignIn = (Get-Content (Join-Path $modelRoot 'ServicePrincipalSignIn-model.json') -Raw | ConvertFrom-Json).value[0]

		@($user.PSObject.Properties.Name) | Should -Be @('isZtModelRow', 'id', 'displayName', 'userPrincipalName', 'accountEnabled', 'userType', 'passwordPolicies', 'createdDateTime', 'onPremisesSyncEnabled', 'externalUserState', 'signInActivity')
		@($user.PSObject.Properties.Name) | Should -Not -Contain 'assignedPlans'
		@($user.PSObject.Properties.Name) | Should -Not -Contain 'assignedLicenses'
		@($user.signInActivity.PSObject.Properties.Name) | Should -Contain 'lastSuccessfulSignInDateTime'

		@($application.PSObject.Properties.Name) | Should -Be @('isZtModelRow', '@odata.type', 'id', 'appId', 'displayName', 'signInAudience', 'passwordCredentials', 'keyCredentials', 'servicePrincipalLockConfiguration', 'tags', 'customSecurityAttributes')
		@($application.passwordCredentials[0].PSObject.Properties.Name) | Should -Contain 'endDateTime'
		@($application.keyCredentials[0].PSObject.Properties.Name) | Should -Contain 'startDateTime'
		@($application.keyCredentials[0].PSObject.Properties.Name) | Should -Contain 'endDateTime'
		@($application.servicePrincipalLockConfiguration.PSObject.Properties.Name) | Should -Contain 'isEnabled'

		@($servicePrincipal.PSObject.Properties.Name) | Should -Be @('isZtModelRow', '@odata.type', 'id', 'appId', 'displayName', 'appOwnerOrganizationId', 'publisherName', 'signInAudience', 'passwordCredentials', 'keyCredentials', 'servicePrincipalType', 'accountEnabled', 'tags', 'customSecurityAttributes', 'agentIdentityBlueprintId', 'createdByAppId', 'preferredSingleSignOnMode', 'appRoleAssignmentRequired', 'appRoles', 'replyUrls', 'appRoleAssignments', 'oauth2PermissionGrants', 'owners')
		@($servicePrincipal.passwordCredentials[0].PSObject.Properties.Name) | Should -Contain 'endDateTime'
		@($servicePrincipal.keyCredentials[0].PSObject.Properties.Name) | Should -Contain 'startDateTime'
		@($servicePrincipal.keyCredentials[0].PSObject.Properties.Name) | Should -Contain 'endDateTime'
		@($servicePrincipal.appRoles[0].PSObject.Properties.Name) | Should -Contain 'id'
		@($servicePrincipal.appRoles[0].PSObject.Properties.Name) | Should -Contain 'value'
		@($servicePrincipal.appRoleAssignments[0].PSObject.Properties.Name) | Should -Contain 'appRoleId'
		@($servicePrincipal.oauth2PermissionGrants[0].PSObject.Properties.Name) | Should -Contain 'scope'

		@($signIn.PSObject.Properties.Name) | Should -Be @('isZtModelRow', 'createdDateTime', 'deviceDetail', 'conditionalAccessStatus', 'authenticationRequirement', 'isInteractive', 'status')
		@($signIn.deviceDetail.PSObject.Properties.Name) | Should -Be @('browser', 'operatingSystem', 'displayName', 'deviceId', 'trustType', 'isCompliant', 'isManaged')
		@($signIn.status.PSObject.Properties.Name) | Should -Be @('failureReason', 'additionalDetails', 'errorCode')

		@($servicePrincipalSignIn.PSObject.Properties.Name) | Should -Be @('isZtModelRow', 'applicationAuthenticationClientSignInActivity', 'delegatedClientSignInActivity', 'appId', 'applicationAuthenticationResourceSignInActivity', 'delegatedResourceSignInActivity', 'lastSignInActivity', 'id')
		foreach ($activityName in @('applicationAuthenticationClientSignInActivity', 'delegatedClientSignInActivity', 'applicationAuthenticationResourceSignInActivity', 'delegatedResourceSignInActivity', 'lastSignInActivity')) {
			@($servicePrincipalSignIn.$activityName.PSObject.Properties.Name) | Should -Be @('lastSignInRequestId', 'lastSignInDateTime')
		}
	}
}

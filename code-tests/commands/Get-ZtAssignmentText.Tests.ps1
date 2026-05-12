Describe "Get-ZtAssignmentText" {
	BeforeAll {
		$here = $PSScriptRoot
		$srcRoot = Join-Path $here "../../src/powershell"

		# Mock external module dependencies before loading SUTs
		if (-not (Get-Command Write-PSFMessage -ErrorAction SilentlyContinue)) {
			function global:Write-PSFMessage {
				param($Level, $Message, $StringValues, $ErrorRecord, $Tag)
			}
		}
		if (-not (Get-Command Invoke-ZtGraphRequest -ErrorAction SilentlyContinue)) {
			function global:Invoke-ZtGraphRequest {
				param($RelativeUri, $ErrorAction)
			}
		}

		# Load the SUT and its dependencies
		. (Join-Path $srcRoot "private/core/Get-ZtHttpStatusCode.ps1")
		. (Join-Path $srcRoot "private/graph/Get-ZtAssignmentText.ps1")

		# ---------------------------------------------------------------------------
		# Helper: build a minimal assignment object
		# ---------------------------------------------------------------------------
		function script:New-GroupAssignment {
			param([string]$GroupId)
			[PSCustomObject]@{
				target = [PSCustomObject]@{
					'@odata.type' = '#microsoft.graph.groupAssignmentTarget'
					groupId       = $GroupId
				}
			}
		}

		function script:New-AllUsersAssignment {
			[PSCustomObject]@{
				target = [PSCustomObject]@{
					'@odata.type' = '#microsoft.graph.allLicensedUsersAssignmentTarget'
				}
			}
		}

		function script:New-AllDevicesAssignment {
			[PSCustomObject]@{
				target = [PSCustomObject]@{
					'@odata.type' = '#microsoft.graph.allDevicesAssignmentTarget'
				}
			}
		}
	}

	BeforeEach {
		Mock Write-PSFMessage {}
		Mock Invoke-ZtGraphRequest {}
	}

	# ---------------------------------------------------------------------------
	# Well-known assignment targets
	# ---------------------------------------------------------------------------
	Context "Known assignment target types" {
		It "Returns 'All users' for allLicensedUsersAssignmentTarget" {
			$result = Get-ZtAssignmentText @(New-AllUsersAssignment)

			$result | Should -Be "All users"
		}

		It "Returns 'All devices' for allDevicesAssignmentTarget" {
			$result = Get-ZtAssignmentText @(New-AllDevicesAssignment)

			$result | Should -Be "All devices"
		}

		It "Returns 'Unknown target' for an unrecognised odata type" {
			$assignment = [PSCustomObject]@{
				target = [PSCustomObject]@{ '@odata.type' = '#microsoft.graph.someUnknownTarget' }
			}

			$result = Get-ZtAssignmentText @($assignment)

			$result | Should -Be "Unknown target"
		}
	}

	# ---------------------------------------------------------------------------
	# Group resolution — happy path
	# ---------------------------------------------------------------------------
	Context "Group resolution - successful lookup" {
		It "Returns the group displayName when Graph resolves successfully" {
			Mock Invoke-ZtGraphRequest { [PSCustomObject]@{ displayName = "Finance Team" } }

			$result = Get-ZtAssignmentText @(New-GroupAssignment "group-guid-1")

			$result | Should -Be "Finance Team"
		}

		It "Falls back to raw groupId when Graph returns null (empty response)" {
			Mock Invoke-ZtGraphRequest { $null }

			$result = Get-ZtAssignmentText @(New-GroupAssignment "group-guid-null")

			$result | Should -Be "group-guid-null"
		}

		It "Calls Invoke-ZtGraphRequest with the correct groupId in the URI" {
			Mock Invoke-ZtGraphRequest { [PSCustomObject]@{ displayName = "Sales" } }

			Get-ZtAssignmentText @(New-GroupAssignment "abc-123") | Out-Null

			Should -Invoke Invoke-ZtGraphRequest -Times 1 -Exactly -ParameterFilter {
				$RelativeUri -like "*abc-123*"
			}
		}

		It "Calls Invoke-ZtGraphRequest with -ErrorAction Stop" {
			Mock Invoke-ZtGraphRequest { [PSCustomObject]@{ displayName = "HR" } }

			Get-ZtAssignmentText @(New-GroupAssignment "group-ea-stop") | Out-Null

			Should -Invoke Invoke-ZtGraphRequest -Times 1 -Exactly -ParameterFilter {
				$ErrorAction -eq 'Stop'
			}
		}
	}

	# ---------------------------------------------------------------------------
	# Group resolution — 404 / 410 (deleted group)
	# ---------------------------------------------------------------------------
	Context "Group resolution - deleted group (404 / 410)" {
		It "Returns the raw groupId and does NOT throw on HTTP 404" {
			Mock Invoke-ZtGraphRequest {
				throw "Response status code does not indicate success: 404 (Not Found)."
			}

			$result = { Get-ZtAssignmentText @(New-GroupAssignment "deleted-group-id") } | Should -Not -Throw
			$result = Get-ZtAssignmentText @(New-GroupAssignment "deleted-group-id")

			$result | Should -Be "deleted-group-id"
		}

		It "Returns the raw groupId and does NOT throw on HTTP 410 (Gone)" {
			Mock Invoke-ZtGraphRequest {
				throw "Response status code does not indicate success: 410 (Gone)."
			}

			{ Get-ZtAssignmentText @(New-GroupAssignment "gone-group-id") } | Should -Not -Throw

			$result = Get-ZtAssignmentText @(New-GroupAssignment "gone-group-id")
			$result | Should -Be "gone-group-id"
		}

		It "Logs a Verbose message when a group returns 404" {
			Mock Invoke-ZtGraphRequest {
				throw "Response status code does not indicate success: 404 (Not Found)."
			}

			Get-ZtAssignmentText @(New-GroupAssignment "deleted-group-id") | Out-Null

			Should -Invoke Write-PSFMessage -Times 1 -Exactly -ParameterFilter {
				$Level -eq 'Verbose' -and $Tag -eq 'Graph' -and $Message -like "*deleted-group-id*"
			}
		}

		It "Logs a Verbose message when a group returns 410" {
			Mock Invoke-ZtGraphRequest {
				throw "Response status code does not indicate success: 410 (Gone)."
			}

			Get-ZtAssignmentText @(New-GroupAssignment "gone-group-id") | Out-Null

			Should -Invoke Write-PSFMessage -Times 1 -Exactly -ParameterFilter {
				$Level -eq 'Verbose' -and $Tag -eq 'Graph'
			}
		}

		It "Continues processing remaining assignments after a 404 on one group" {
			$script:callCount = 0
			Mock Invoke-ZtGraphRequest {
				$script:callCount++
				if ($script:callCount -eq 1) {
					throw "Response status code does not indicate success: 404 (Not Found)."
				}
				[PSCustomObject]@{ displayName = "Existing Group" }
			}

			$assignments = @(
				New-GroupAssignment "deleted-group-id"
				New-GroupAssignment "existing-group-id"
			)

			$result = Get-ZtAssignmentText $assignments

			$result | Should -Be "deleted-group-id, Existing Group"
		}
	}

	# ---------------------------------------------------------------------------
	# Group resolution — non-404 errors must rethrow
	# ---------------------------------------------------------------------------
	Context "Group resolution - non-404 errors rethrow" {
		It "Throws on HTTP 403 Forbidden" {
			Mock Invoke-ZtGraphRequest {
				throw "Response status code does not indicate success: 403 (Forbidden)."
			}

			{ Get-ZtAssignmentText @(New-GroupAssignment "group-id") } | Should -Throw "*403*"
		}

		It "Throws on HTTP 401 Unauthorized" {
			Mock Invoke-ZtGraphRequest {
				throw "Response status code does not indicate success: 401 (Unauthorized)."
			}

			{ Get-ZtAssignmentText @(New-GroupAssignment "group-id") } | Should -Throw "*401*"
		}

		It "Throws on HTTP 500 Internal Server Error" {
			Mock Invoke-ZtGraphRequest {
				throw "Response status code does not indicate success: 500 (Internal Server Error)."
			}

			{ Get-ZtAssignmentText @(New-GroupAssignment "group-id") } | Should -Throw "*500*"
		}

		It "Throws on network-level error (no HTTP status code)" {
			Mock Invoke-ZtGraphRequest {
				throw "The remote name could not be resolved: 'graph.microsoft.com'"
			}

			{ Get-ZtAssignmentText @(New-GroupAssignment "group-id") } | Should -Throw "*remote name*"
		}

		It "Does NOT write a Verbose log on non-404 errors" {
			Mock Invoke-ZtGraphRequest {
				throw "Response status code does not indicate success: 403 (Forbidden)."
			}

			{ Get-ZtAssignmentText @(New-GroupAssignment "group-id") } | Should -Throw

			Should -Invoke Write-PSFMessage -Times 0 -Exactly
		}
	}

	# ---------------------------------------------------------------------------
	# Multiple assignments / mixed types
	# ---------------------------------------------------------------------------
	Context "Multiple assignments" {
		It "Joins multiple resolved group names with a comma-space separator" {
			Mock Invoke-ZtGraphRequest {
				param($RelativeUri)
				if ($RelativeUri -like "*group-a*") { return [PSCustomObject]@{ displayName = "Alpha" } }
				if ($RelativeUri -like "*group-b*") { return [PSCustomObject]@{ displayName = "Beta" } }
			}

			$assignments = @(
				New-GroupAssignment "group-a"
				New-GroupAssignment "group-b"
			)

			$result = Get-ZtAssignmentText $assignments

			$result | Should -Be "Alpha, Beta"
		}

		It "Handles mixed targets: All users, group, All devices" {
			Mock Invoke-ZtGraphRequest { [PSCustomObject]@{ displayName = "Admins" } }

			$assignments = @(
				New-AllUsersAssignment
				New-GroupAssignment "group-id"
				New-AllDevicesAssignment
			)

			$result = Get-ZtAssignmentText $assignments

			$result | Should -Be "All users, Admins, All devices"
		}

		It "Returns empty string when assignments list is empty" {
			$result = Get-ZtAssignmentText @()

			$result | Should -Be ""
		}

		It "Returns empty string when assignments is null" {
			$result = Get-ZtAssignmentText $null

			$result | Should -Be ""
		}
	}
}

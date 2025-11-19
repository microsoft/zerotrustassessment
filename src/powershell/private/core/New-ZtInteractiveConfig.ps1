<#
.SYNOPSIS
Creates a Zero Trust Assessment configuration file using an interactive text-based user interface.

.DESCRIPTION
This function provides a text-based user interface (TUI) for creating Zero Trust Assessment configuration files.
The generated .json file can be used internally by the Invoke-ZtAssessment function.

.EXAMPLE
New-ZtInteractiveConfig

Creates a configuration file using the TUI interface and saves it to the temporary directory.

.INPUTS
None. You cannot pipe objects to this function.

.OUTPUTS
System.IO.FileInfo. Returns the created configuration file object.

.NOTES
Requires PowerShell 7+ and the PwshSpectreConsole module.
Use 'Install-Module PwshSpectreConsole' to install the required module.
#>

function New-ZtInteractiveConfig {
    [CmdletBinding()]
    [OutputType([System.IO.FileInfo])]
    param (
        # No parameters needed
    )

    # Create the output file path in temporary folder
    $tempPath = [System.IO.Path]::GetTempPath()
    $OutputPath = Join-Path $tempPath "zt-interactive-config.json"

    # Enhanced header with better visual appeal
    Clear-Host
    $headerText = "Zero Trust Assessment Configuration Wizard"
    $headerEmoji = "🛡️"
    $headerDisplay = if ($Host.UI.SupportsVirtualTerminal) { "$headerEmoji $headerText" } else { $headerText }
    Write-SpectreRule $headerDisplay -Color ([Spectre.Console.Color]::Blue)
    Write-Host
    Write-SpectreHost "[dim]Welcome to the interactive configuration wizard.[/]"
    Write-SpectreHost "[dim]This tool will help you create a custom configuration for your Zero Trust Assessment.[/]"
    Write-Host
    Write-SpectreRule "Step 1: Assessment Settings" -Color ([Spectre.Console.Color]::Cyan1)

    # Create configuration hashtable
    $configData = @{}

    try {
        # Collect Days setting with better description
        Write-SpectreHost "[bold cyan1]📊 Sign-in Log Query Duration[/]"
        Write-SpectreHost "[dim]How many days of sign-in logs would you like to analyze?[/]"
        Write-SpectreHost "[dim]• More days = more comprehensive analysis[/]"
        Write-SpectreHost "[dim]• Fewer days = faster processing[/]"
        Write-Host

        # Loop until a valid number of days is provided
        do {
            $days = Read-SpectreText -Prompt "[cyan1]Number of days[/] [dim](1-30)[/]" -DefaultAnswer "30"
            $daysValid = $days -as [int] -and 1 -le $days -and 30 -ge $days
            if (-not $daysValid) {
                Write-SpectreHost "[red]❌ Please enter a number between 1 and 30.[/]"
            }
        } while (-not $daysValid)
        $configData.Days = [int]$days
        Write-SpectreHost "[green]✅ Will analyze $days days of sign-in logs[/]"
        Write-Host

        # Collect Maximum query time with better explanation
        Write-SpectreHost "[bold cyan1]⏱️ Query Time Limit[/]"
        Write-SpectreHost "[dim]Set a maximum time limit for querying sign-in logs to prevent long waits.[/]"
        Write-SpectreHost "[dim]• 0 = No time limit (may take longer)[/]"
        Write-SpectreHost "[dim]• Recommended: 60 minutes for most environments[/]"
        Write-Host

        do {
            $maxTime = Read-SpectreText -Prompt "[cyan1]Maximum query time in minutes[/] [dim](0 = no limit)[/]" -DefaultAnswer "60"
            $maxTimeValid = $maxTime -match '^\d+$' -and [int]$maxTime -ge 0
            if (-not $maxTimeValid) {
                Write-SpectreHost "[red]❌ Please enter a number 0 or greater.[/]"
            }
        } while (-not $maxTimeValid)
        $configData.MaximumSignInLogQueryTime = [int]$maxTime

        if ([int]$maxTime -eq 0) {
            Write-SpectreHost "[yellow]⚠️ No time limit set - assessment may take longer[/]"
        } else {
            Write-SpectreHost "[green]✅ Query time limit set to $maxTime minutes[/]"
        }
        Write-Host

        # Collect output path with better guidance
        Write-SpectreHost "[bold cyan1]📁 Report Output Location[/]"
        Write-SpectreHost "[dim]Where would you like to save the assessment report?[/]"
        Write-Host

        $reportPath = Read-SpectreText -Prompt "[cyan1]Report output path[/]" -DefaultAnswer "./ZeroTrustReport"
        $configData.Path = $reportPath
        Write-SpectreHost "[green]✅ Report will be saved to: $reportPath[/]"
        Write-Host

        # Enhanced configuration options section
        Write-SpectreRule "Step 2: Advanced Options" -Color ([Spectre.Console.Color]::Cyan1)
        Write-Host
        Write-SpectreHost "[bold cyan1]🔧 Additional Configuration Options[/]"
        Write-SpectreHost "[dim]These options provide additional functionality for your assessment.[/]"
        Write-Host

        # Display available options with better descriptions
        $options = @(
            "Enable detailed logging",
            "Export logs to support package",
            "Disable telemetry collection",
            "Resume from previous export"
        )

        $optionDescriptions = @{
            "Enable detailed logging" = "Shows verbose output during assessment execution"
            "Export logs to support package" = "Creates diagnostic files for troubleshooting"
            "Disable telemetry collection" = "Prevents sending anonymous usage data to Microsoft"
            "Resume from previous export" = "Continues from a previously interrupted assessment"
        }

        Write-SpectreHost "[bold yellow]Available Options:[/]"
        for ($i = 0; $i -lt $options.Count; $i++) {
            $option = $options[$i]
            $description = $optionDescriptions[$option]
            Write-SpectreHost "  [bold]$($i + 1). $option[/]"
            Write-SpectreHost "     [dim]$description[/]"
        }
        $selectionMethod = Read-SpectreSelection -Prompt "[cyan1]How would you like to configure these options?[/]" -Choices @(
            "🎯 Select options individually (recommended)",
            "✅ Select all options",
            "⏭️ Skip all options (use defaults)"
        )

        $selectedOptions = @()

        switch ($selectionMethod) {
            "🎯 Select options individually (recommended)" {
                Write-Host
                Write-SpectreHost "[bold cyan1]Interactive Selection Mode[/]"
                Write-SpectreHost "[dim]• Use [bold]SPACE[/] to toggle options on/off[/]"
                Write-SpectreHost "[dim]• Use [bold]ENTER[/] to confirm your selection[/]"
                Write-SpectreHost "[dim]• Use [bold]arrow keys[/] to navigate[/]"
                Write-Host
                $selectedOptions = Read-SpectreMultiSelection -Prompt "[cyan1]Select your desired options[/]" -Choices $options -AllowEmpty
            }
            "✅ Select all options" {
                $selectedOptions = $options
                Write-Host
                Write-SpectreHost "[bold green]✅ All options selected[/]"
                Write-SpectreHost "[dim]The assessment will run with all advanced features enabled.[/]"
            }
            "⏭️ Skip all options (use defaults)" {
                $selectedOptions = @()
                Write-Host
                Write-SpectreHost "[bold yellow]⏭️ Using default settings[/]"
                Write-SpectreHost "[dim]The assessment will run with standard configuration.[/]"
            }
        }

        # Show selected options summary
        if ($selectedOptions.Count -gt 0) {
            Write-Host
            Write-SpectreHost "[bold green]Selected Options Summary:[/]"
            foreach ($option in $selectedOptions) {
                Write-SpectreHost "  [green]✅[/] $option"
            }
        }

        $configData.ShowLog = $selectedOptions -contains "Enable detailed logging"
        $configData.ExportLog = $selectedOptions -contains "Export logs to support package"
        $configData.DisableTelemetry = $selectedOptions -contains "Disable telemetry collection"
        $configData.Resume = $selectedOptions -contains "Resume from previous export"

        # Enhanced test IDs collection
        Write-Host
        Write-SpectreRule "Step 3: Test Selection (Optional)" -Color ([Spectre.Console.Color]::Cyan1)
        Write-Host
        Write-SpectreHost "[bold cyan1]🧪 Specific Test Selection[/]"
        Write-SpectreHost "[dim]By default, all available tests will be executed.[/]"
        Write-SpectreHost "[dim]You can optionally specify specific test IDs to run only those tests.[/]"
        Write-Host

        $testIds = Read-SpectreText -Prompt "[cyan1]Specific test IDs[/] [dim](comma-separated, leave empty for all tests)[/]" -AllowEmpty
        if (![string]::IsNullOrWhiteSpace($testIds)) {
            $testArray = $testIds -split ',' | ForEach-Object { $_.Trim() } | Where-Object { $_ }
            $invalidIds = $testArray | Where-Object { $_ -notmatch '^\d+$' }
            if ($invalidIds.Count -gt 0) {
                Write-SpectreHost "[red]❌ Invalid test IDs detected: $($invalidIds -join ', ')[/]"
                Write-SpectreHost "[dim]Test IDs must only contain numbers.[/]"
                throw "Invalid test IDs provided."
            }
            if ($testArray.Count -gt 0) {
                $configData.Tests = $testArray
                Write-SpectreHost "[green]✅ Will run $($testArray.Count) specific test(s): $($testArray -join ', ')[/]"
            }
        } else {
            Write-SpectreHost "[green]✅ Will run all available tests[/]"
        }

        # Enhanced preview section
        Write-Host
        Write-SpectreRule "Step 4: Review & Save" -Color ([Spectre.Console.Color]::Cyan1)
        Write-Host

        $showPreview = Read-SpectreConfirm -Prompt "[cyan1]Would you like to preview your configuration?[/]" -DefaultAnswer "y"

        if ($showPreview) {
            Write-Host
            Write-SpectreRule "📋 Configuration Preview" -Color ([Spectre.Console.Color]::Green)

            # Create a more readable preview format
            Write-SpectreHost "[bold yellow]Assessment Configuration Summary:[/]"
            Write-SpectreHost "  [cyan1]Days to analyze:[/] $($configData.Days)"
            Write-SpectreHost "  [cyan1]Query time limit:[/] $($configData.MaximumSignInLogQueryTime) minutes"
            Write-SpectreHost "  [cyan1]Report output path:[/] $($configData.Path)"
            Write-SpectreHost "  [cyan1]Detailed logging:[/] $($configData.ShowLog)"
            Write-SpectreHost "  [cyan1]Export logs:[/] $($configData.ExportLog)"
            Write-SpectreHost "  [cyan1]Telemetry disabled:[/] $($configData.DisableTelemetry)"
            Write-SpectreHost "  [cyan1]Resume mode:[/] $($configData.Resume)"

            if ($configData.Tests) {
                Write-SpectreHost "  [cyan1]Specific tests:[/] $($configData.Tests -join ', ')"
            } else {
                Write-SpectreHost "  [cyan1]Test selection:[/] All tests"
            }

            Write-Host
        }

        $saveConfig = Read-SpectreConfirm -Prompt "[bold cyan1]💾 Save this configuration?[/]" -DefaultAnswer "y"

        if (-not $saveConfig) {
            Write-Host
            Write-SpectreRule "❌ Configuration Cancelled" -Color ([Spectre.Console.Color]::Red)
            Write-SpectreHost "[yellow]Configuration creation cancelled by user.[/]"
            Write-SpectreHost "[dim]No configuration file was created. You can run this wizard again anytime.[/]"
            Write-Host
            return $null
        }

        # Generate and save configuration file as JSON in temporary folder
		$configData | Export-PSFJson -Path $OutputPath -Depth 3 -Encoding UTF8NoBom

        # Enhanced success message
        Write-Host
        Write-SpectreRule "🎉 Configuration Created Successfully!" -Color ([Spectre.Console.Color]::Green)
        Write-SpectreHost "[bold green]✅ Configuration file created successfully![/]"
        Write-SpectreHost "[green]📁 Location:[/] [white]$OutputPath[/]"
        Write-SpectreHost "[dim]This temporary file will be moved to your report directory when the assessment starts.[/]"
        Write-Host
        Write-SpectreHost "[bold cyan1]🚀 Ready to start your Zero Trust Assessment![/]"
        Write-Host

        Get-Item $OutputPath
    }
    catch {
        Write-Host
        Write-SpectreRule "❌ Error Occurred" -Color ([Spectre.Console.Color]::Red)
        Write-SpectreHost "[red]An error occurred: $($_.Exception.Message)[/]"
        Write-Host
        throw
    }
}

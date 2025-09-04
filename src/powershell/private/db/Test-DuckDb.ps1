<#
.SYNOPSIS
    Validates that DuckDB is installed and provide instruction on how to install.
#>

function Test-DuckDb
{
	[CmdletBinding()]
	param (

	)

    try {
        Connect-Database # Try connecting with in memory db
        return $true
    }
    catch {
        Write-PSFMessage $_.Exception.Message -Level Debug # Log silently

        # Check for specific DuckDB initialization error that indicates missing Visual C++ Redistributable
        if ($_.Exception.Message -like "*The type initializer for 'DuckDB.NET*") {
            Write-Host
            Write-Host "⚠️ PREREQUISITE REQUIRED: Visual C++ Redistributable is missing" -ForegroundColor Red
            Write-Host "ZeroTrustAssessment requires the Microsoft Visual C++ Redistributable to function properly." -ForegroundColor Yellow
            Write-Host "Please download and install it from: https://aka.ms/vcredist" -ForegroundColor Yellow
            Write-Host "After installation, restart PowerShell and try running the assessment again." -ForegroundColor Yellow
            Write-Host
        }
        else {
            # Throw exceptions
            throw $_.Exception
        }
        return $false
    }
}

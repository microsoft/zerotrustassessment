function Test-DatabaseAssembly
{
	<#
	.SYNOPSIS
		Validates that DuckDB is installed and provides instruction on how to install.

	.DESCRIPTION
		Validates that DuckDB is installed and provides instruction on how to install.
		This is done by connecting to the automatic in-memory database.
		If that works, then the database binaries must be ready to work.

	.EXAMPLE
		PS C:\> Test-DatabaseAssembly

		Validates that DuckDB is installed and - if needed - provides instruction on how to install.
	#>
	[CmdletBinding()]
	param ()

    try {
		# Try connecting with in memory db. Should always work if the assemblies can be loaded
        $null = Connect-Database -Transient
        Write-Host -Object '  ✅ Database engine (DuckDB) is ready.' -ForegroundColor Green
        return $true
    }
    catch {
        Write-PSFMessage 'Database binaries not ready to use' -ErrorRecord $_ -Tag DB -Level Debug # Log silently

        # Check for specific DuckDB initialization error that indicates missing Visual C++ Redistributable
        if ($_.Exception.Message -like "*The type initializer for 'DuckDB.NET*") {
            $runtimeArch = [System.Runtime.InteropServices.RuntimeInformation]::ProcessArchitecture
            Write-Host
            if ($IsWindows) {
                if ($runtimeArch -eq 'Arm64') {
                    Write-Host "⚠️ UNSUPPORTED PLATFORM: Windows ARM64" -ForegroundColor Red
                    Write-Host "Windows on ARM devices are not currently supported." -ForegroundColor Yellow
                }
                else {
                    Write-Host "⚠️ PREREQUISITE REQUIRED: Visual C++ Redistributable is missing" -ForegroundColor Red
                    Write-Host "ZeroTrustAssessment requires the Microsoft Visual C++ Redistributable to function properly." -ForegroundColor Yellow
                    Write-Host "Please download and install it from: https://aka.ms/vcredist" -ForegroundColor Yellow
                    Write-Host "After installation, restart PowerShell and try running the assessment again." -ForegroundColor Yellow
                }
            }
            else {
                Write-Host "⚠️ DuckDB native library failed to load ($runtimeArch)" -ForegroundColor Red
                if ($global:__ZtDependenciesInitialized) {
                    Write-Host "The module's dependency initialization ran but DuckDB still failed to load." -ForegroundColor Yellow
                    Write-Host "This may indicate a version mismatch or missing system libraries." -ForegroundColor Yellow
                }
                $libDir = Join-Path -Path $script:ModuleRoot -ChildPath 'lib'
                $targetLib = Join-Path -Path $libDir -ChildPath 'libduckdb.so'
                if (Test-Path -Path $targetLib) {
                    Write-Host "The library lib/libduckdb.so exists but failed to load." -ForegroundColor Yellow
                    Write-Host "It may be the wrong version or have missing system dependencies (try: ldd $targetLib)." -ForegroundColor Yellow
                    Write-Host "Error: $($_.Exception.Message)" -ForegroundColor Yellow
                }
                else {
                    Write-Host "The native library lib/libduckdb.so is missing." -ForegroundColor Yellow
                    Write-Host "Download the $runtimeArch build from: https://github.com/duckdb/duckdb/releases" -ForegroundColor Yellow
                    Write-Host "Place libduckdb.so in: $libDir" -ForegroundColor Yellow
                }
            }
            Write-Host
        }
        else {
            # Throw exceptions
            throw
        }
        return $false
    }
}

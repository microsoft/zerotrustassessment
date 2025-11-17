# ------------------------------------------------------------------------------
#  Copyright (c) Microsoft Corporation.  All Rights Reserved.  Licensed under the MIT License.  See License in the project root for license information.
# ------------------------------------------------------------------------------

Set-StrictMode -Version 5

. "$psscriptroot/common-functions.ps1"

$moduleNames = Get-ModuleName

foreach($moduleName in $moduleNames){
    $modulePath = Join-Path (Get-ModuleBasePath) $moduleName
    $modulePsd1 = $modulePath + ".psd1"
    ($modulePsd1 | Get-AuthenticodeSignature).Status | Should -Be "Valid"
    
    if(($moduleName -eq 'Microsoft.Entra') -or ($moduleName -eq 'Microsoft.Entra.Beta')){
		continue
	}
    $modulePsm1 = $modulePath + ".psm1"
    ($modulePsm1 | Get-AuthenticodeSignature).Status | Should -Be "Valid"    
}
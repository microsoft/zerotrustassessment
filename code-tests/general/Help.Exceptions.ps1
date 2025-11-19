$global:__testData.Tests.Help = @{ }
# List of functions that should be ignored
$global:__testData.Tests.Help.Exempt = @(

)

<#
  List of arrayed enumerations. These need to be treated differently. Add full name.
  Example:

  "Sqlcollaborative.Dbatools.Connection.ManagementConnectionType[]"
#>
$global:__testData.Tests.Help.EnumeratedArrays = @(

)

<#
  Some types on parameters just fail their validation no matter what.
  For those it becomes possible to skip them, by adding them to this hashtable.
  Add by following this convention: <command name> = @(<list of parameter names>)
  Example:

  "Get-DbaCmObject"       = @("DoNotUse")
#>
$global:__testData.Tests.Help.SkipParameterType = @{

}

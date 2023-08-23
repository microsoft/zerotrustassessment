using System;
using System.Management.Automation;
using System.Management.Automation.Runspaces;

namespace ZeroTrustAssessment;

[Cmdlet("Invoke",$"{Consts.ModulePrefix}Assessment")]
[OutputType(typeof(FavoriteStuff))]
public class InvokeZtAssessmentCmdletCommand : PSCmdlet
{
    [Parameter(
        Mandatory = true,
        Position = 0,
        ValueFromPipeline = true,
        ValueFromPipelineByPropertyName = true)]
    public string Path { get; set; }

    [Parameter(
        Mandatory = true,
        Position = 1,
        ValueFromPipelineByPropertyName = true)]
    public string AccessToken { get; set; }

    // This method gets called once for each cmdlet in the pipeline when the pipeline starts executing
    protected override void BeginProcessing()
    {
        WriteVerbose("Begin!");
    }

    // This method will be called for each input received from the pipeline to this cmdlet; if no input is received, this method is not called
    protected override void ProcessRecord()
    {
        WriteObject("Exporting to ");
    }

    // This method will be called once at the end of pipeline execution; if no input is received, this method is not called
    protected override void EndProcessing()
    {
        WriteVerbose("End!");
    }
}

public class FavoriteStuff
{
    public int FavoriteNumber { get; set; }
    public string FavoritePet { get; set; }
}

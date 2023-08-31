using System;
using System.IO;
using System.Management.Automation;
using Gen = ZeroTrustAssessment.DocumentGenerator;
using ZeroTrustAssessment.DocumentGenerator.Graph;

namespace ZeroTrustAssessment;

[Cmdlet("Invoke", $"{Consts.ModulePrefix}Assessment")]
public class InvokeZtAssessmentCmdletCommand : PSCmdlet
{
    [Parameter(
        Mandatory = true,
        Position = 0,
        ValueFromPipeline = true,
        ValueFromPipelineByPropertyName = true)]
    public string OutputFolder { get; set; }

    [Parameter(
        Mandatory = true,
        Position = 1,
        ValueFromPipelineByPropertyName = true)]
    public string AccessToken { get; set; }

    // This method gets called once for each cmdlet in the pipeline when the pipeline starts executing
    protected override void BeginProcessing()
    {
        if (string.IsNullOrEmpty(AccessToken))
        {
            throw new Exception("Token not found. Please provide a valid token.");
        }
        Syncfusion.Licensing.SyncfusionLicenseProvider.RegisterLicense(Consts.SfKey);
    }

    // This method will be called for each input received from the pipeline to this cmdlet; if no input is received, this method is not called
    protected override void ProcessRecord()
    {        
        var configOptions = new Gen.ConfigOptions();
        var graphData = new GraphData(configOptions, AccessToken);
        graphData.CollectData().GetAwaiter().GetResult();

        var pptxConfigOptions = new IdPowerToys.PowerPointGenerator.ConfigOptions
        {
            GroupSlidesByState = true
        };
        var pptxGraphData = new IdPowerToys.PowerPointGenerator.Graph.GraphData(pptxConfigOptions, AccessToken);
        pptxGraphData.CollectData().GetAwaiter().GetResult();

        var gen = new Gen.DocumentGenerator();

        if(!Path.Exists(OutputFolder))
        {
            Directory.CreateDirectory(OutputFolder);
        }

        var timestamp = DateTime.Now.ToString("yyyy-MM-ddTHHmmss");
        var saveFilePath = Path.Combine(OutputFolder, $@"ZeroTrustAssessment-{timestamp}.xlsx");
        using (var stream = new FileStream(saveFilePath, FileMode.Create))
        {
            gen.GenerateDocumentAsync(graphData, pptxGraphData, stream, configOptions).GetAwaiter().GetResult();
            stream.Position = 0;
        }
        WriteInformation($"Assessment generated at {saveFilePath}", Consts.WriteInformationTagHost);
    }

    // This method will be called once at the end of pipeline execution; if no input is received, this method is not called
    protected override void EndProcessing()
    {
        WriteVerbose("End!");
    }
}

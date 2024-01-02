using System.Management.Automation;
using ZeroTrustAssessment.DocumentGenerator.Infrastructure;
using ZeroTrustAssessment.DocumentGenerator;
using Syncfusion.XlsIO;

namespace ZeroTrustAssessment;

[Cmdlet(VerbsCommon.Set, $"{Consts.ModulePrefix}TemplateDocLinks")]
[CmdletBinding(DefaultParameterSetName = "Default")]
public class SetTemplateDocLinks : PSCmdlet
{

    [Parameter(
        HelpMessage = "Path to the Zero Trust spreadsheet template file.",
        ParameterSetName = "Default",
        Mandatory = true,
        Position = 0,
        ValueFromPipeline = true,
        ValueFromPipelineByPropertyName = true)]
    public string FilePath { get; set; }

    // This method gets called once for each cmdlet in the pipeline when the pipeline starts executing
    protected override void BeginProcessing()
    {
        Syncfusion.Licensing.SyncfusionLicenseProvider.RegisterLicense(Consts.SfKey);
    }

    // This method will be called for each input received from the pipeline to this cmdlet; if no input is received, this method is not called
    protected override void ProcessRecord()
    {
        IWorkbook workbook = ExcelHelper.OpenWorkbookFile(FilePath);

        var ztWorkbook = new ZtWorkbook(workbook);
        ztWorkbook.SetTemplateDocLinks();

        var newPath = FilePath.Replace(".xlsx", "-updated.xlsx");
        ExcelHelper.SaveWorkbookFile(workbook, newPath);
        WriteInformation($"Completed updating template.", Consts.WriteInformationTagHost);
    }

    // This method will be called once at the end of pipeline execution; if no input is received, this method is not called
    protected override void EndProcessing()
    {
        WriteVerbose("End!");
    }

 
}

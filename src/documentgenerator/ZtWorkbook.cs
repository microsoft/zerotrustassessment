using Syncfusion.XlsIO;
using ZeroTrustAssessment.DocumentGenerator.Graph;
using ZeroTrustAssessment.DocumentGenerator.Sheets;

namespace ZeroTrustAssessment.DocumentGenerator;

public enum ZtSheets
{
    Home,
    WorkshopIdentity,
    WorkshopDevice,
    ConfigIdentity,
    ConfigDevice,
    AssessmentIdentity,
    AssessmentDevice
}

public class ZtWorkbook
{
    private readonly IWorkbook _workbook;
    private readonly GraphData _graphData;

    public ZtWorkbook(IWorkbook workbook, GraphData graphData)
    {
        _workbook = workbook;
        _graphData = graphData;
    }

    public async Task GenerateDocumentAsync(IdPowerToys.PowerPointGenerator.Graph.GraphData pptxGraphData)
    {
        var sheetAssessmentDevice = new SheetAssessmentDevice(_workbook, ZtSheets.AssessmentDevice, _graphData);
        var deviceScore = sheetAssessmentDevice.Generate();

        var sheetAssessmentIdentity = new SheetAssessmentIdentity(_workbook, ZtSheets.AssessmentIdentity, _graphData);
        var identityScore = sheetAssessmentIdentity.Generate();

        var sheetConfigDevice = new SheetConfigDevice(_workbook, ZtSheets.ConfigDevice, _graphData);
        sheetConfigDevice.Generate();

        var sheetConfigIdentity = new SheetConfigIdentity(_workbook, ZtSheets.ConfigIdentity, _graphData);
        sheetConfigIdentity.Generate(pptxGraphData);

        var sheetHome = new SheetHome(_workbook, ZtSheets.Home, _graphData);
        sheetHome.Generate(identityScore, deviceScore);
        var sheet = GetWorksheet(_workbook, ZtSheets.Home);
        sheet.Activate();
        sheet.Range["A1"].Text = string.Empty;
    }

    public static IWorksheet GetWorksheet(IWorkbook workbook, ZtSheets sheet)
    {
        return workbook.Worksheets[(int)sheet];
    }
}
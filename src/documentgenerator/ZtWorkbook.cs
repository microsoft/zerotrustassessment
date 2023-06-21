using Syncfusion.XlsIO;
using ZeroTrustAssessment.DocumentGenerator.Graph;
using ZeroTrustAssessment.DocumentGenerator.Sheets;

namespace ZeroTrustAssessment.DocumentGenerator;

public class ZtWorkbook
{
    private readonly IWorkbook _workbook;
    private readonly GraphData _graphData;

    private enum Sheets
    {
        Home,
        WorkshopIdentity,
        WorkshopDevice,
        ConfigIdentity,
        ConfigDevice,
        AssessmentIdentity,
        AssessmentDevice
    }

    private IWorksheet GetWorksheet(Sheets sheet)
    {
        return _workbook.Worksheets[(int)sheet];
    }

    public ZtWorkbook(IWorkbook workbook, GraphData graphData)
    {
        _workbook = workbook;
        _graphData = graphData;
    }

    public void GenerateDocument()
    {
        var sheetHome = new SheetHome(GetWorksheet(Sheets.Home), _graphData);
        sheetHome.Generate();

        var sheetAssessmentDevice = new SheetAssessmentDevice(GetWorksheet(Sheets.AssessmentDevice), _graphData);
        sheetAssessmentDevice.Generate();

        var sheetAssessmentIdentity = new SheetAssessmentIdentity(GetWorksheet(Sheets.AssessmentIdentity), _graphData);
        sheetAssessmentIdentity.Generate();

        var sheetAssessmentConfig = new SheetConfigDevice(GetWorksheet(Sheets.ConfigDevice), _graphData);
        sheetAssessmentConfig.Generate();

    }
}
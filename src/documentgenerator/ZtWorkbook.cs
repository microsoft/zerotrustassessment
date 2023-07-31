using Syncfusion.XlsIO;
using Syncfusion.XlsIO.Implementation.Collections;
using ZeroTrustAssessment.DocumentGenerator.Graph;
using ZeroTrustAssessment.DocumentGenerator.Infrastructure;
using ZeroTrustAssessment.DocumentGenerator.Sheets;
using ZeroTrustAssessment.DocumentGenerator.ViewModels.Convert;

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
    private readonly GraphData? _graphData;

    public ZtWorkbook(IWorkbook workbook) : this(workbook, null) { }

    public ZtWorkbook(IWorkbook workbook, GraphData? graphData)
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
    }

    public async Task<Roadmap> ConvertToJsonAsync()
    {
        var homeSheet = GetWorksheet(_workbook, ZtSheets.Home);
        var roadmap = new Roadmap();
        roadmap.TenantId = homeSheet.Range[ExcelConstant.HomeHeaderTenantIdLabel].Value;


        if (_workbook.Names is WorkbookNamesCollection names)
        {
            foreach (var name in names)
            {
                var key = name.Name;
                if (key.StartsWith("RMI_") || key.StartsWith("RMD_"))
                {
                    var range = name.RefersToRange;
                    var status = name.RefersToRange.Value;
                    if (status != null)
                    {
                        var task = new RoadmapTask
                        {
                            Id = key,
                            Status = Labels.ConvertStatusLabelToString(status)
                        };

                        var parentRow = range.Row - 1;
                        var column = range.Column;

                        try
                        {
                            var titleRange = name.RefersToRange.Worksheet.Range[parentRow, column, parentRow, column];
                            var title = titleRange.Value;
                            var comment = titleRange.Comment.Text;
                            task.Title = title;
                            task.Description = comment;
                        }
                        catch { }
                        roadmap.Identity.Add(task);
                    };
                }
            }
        }
        return roadmap;
    }

    public static IWorksheet GetWorksheet(IWorkbook workbook, ZtSheets sheet)
    {
        return workbook.Worksheets[(int)sheet];
    }
}
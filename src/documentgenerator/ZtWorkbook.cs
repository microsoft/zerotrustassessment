using Syncfusion.Presentation;
using Syncfusion.XlsIO;
using Syncfusion.XlsIO.Implementation.Collections;
using Syncfusion.XlsIO.Implementation.Shapes;
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
    // WorkshopApps,
    WorkshopData,
    ConfigIdentity,
    ConfigDevice,
    AssessmentIdentity,
    AssessmentDevice
}

public class ZtWorkbook
{
    //The name of the range that has the SheetName that maps to ZtSheets enum.
    private const string SheetNameRangeName = "SheetName";

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
        SetHeaders();

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

    private void SetHeaders()
    {
        var sheetIdentity = GetWorksheet(_workbook, ZtSheets.WorkshopIdentity);
        sheetIdentity.TextBoxes["RoadmapIdTenantId"].Text = _graphData.TenantId;
        sheetIdentity.TextBoxes["RoadmapIdTenantName"].Text = _graphData.TenantName;

        foreach (var sheet in _workbook.Worksheets)
        {
            SetBanner(sheet);
        }
    }

    private void SetBanner(IWorksheet sheet)
    {
        var currentDate = DateTime.Now.ToString("dd MMM yyyy");
        var headerInfo = $"{_graphData.TenantName} | {_graphData.PrimaryDomain} | {_graphData.TenantId} | {currentDate}";

        sheet.TextBoxes[ExcelConstant.BannerTenantNameHomeLabel].Text = headerInfo;

        var logoBackgroundRectangle = sheet.Shapes["bannerLogoBg"]; //Get the logo background

        if (_graphData.OrganizationLogo != null)
        {
            var picture = sheet.Pictures.AddPicture(1, 1, _graphData.OrganizationLogo);
            picture.Top = 10;
            picture.Left = 25;
            picture.Width = picture.Width * 30 / 100;
            picture.Height = picture.Height * 30 / 100;
            picture.AlternativeText = "Organization banner logo";
            //Position the background behind the logo
            logoBackgroundRectangle.Top = picture.Top - 5;
            logoBackgroundRectangle.Left = picture.Left - 5;
            logoBackgroundRectangle.Width = picture.Width + 10;
            logoBackgroundRectangle.Height = picture.Height + 10;
        }
        else
        {
            logoBackgroundRectangle.Remove(); //No logo image, remove the background as well
        }
    }

    private void ClearHeaders()
    {
        foreach (var sheet in _workbook.Worksheets)
        {
            ClearBanner(sheet);
        }
    }

    /// <summary>
    /// Used when generating worksheet from ADO.
    /// </summary>
    /// <param name="sheet"></param>
    private void ClearBanner(IWorksheet sheet)
    {
        sheet.TextBoxes[ExcelConstant.BannerTenantNameHomeLabel].Text = string.Empty;

        var logoBackgroundRectangle = sheet.Shapes["bannerLogoBg"]; //Get the logo background

        logoBackgroundRectangle.Remove(); //No logo image, remove the background as well
    }

    /// <summary>
    /// Reads the roadmap info from the spreadsheet and returns a Roadmap object.
    /// </summary>
    /// <returns></returns>
    public async Task<Roadmap> GetRoadmapAsync()
    {
        var roadmap = new Roadmap();
        var sheetIdentity = GetWorksheet(_workbook, ZtSheets.WorkshopIdentity);
        roadmap.TenantId = sheetIdentity.TextBoxes["RoadmapIdTenantId"].Text.ReplaceLineEndings(string.Empty);
        roadmap.TenantName = sheetIdentity.TextBoxes["RoadmapIdTenantName"].Text.ReplaceLineEndings(string.Empty);

        if (_workbook.Names is WorkbookNamesCollection names)
        {
            foreach (var name in names)
            {
                var key = name.Name;
                var roadmapList = key.StartsWith("RMI_") ? roadmap.Identity :
                    key.StartsWith("RMD_") ? roadmap.Device :
                    key.StartsWith("RMDS_") ? roadmap.DevSecOps :
                    key.StartsWith("RMT_") ? roadmap.Data : null;

                if (roadmapList != null)
                {
                    var range = name.RefersToRange;
                    var status = name.RefersToRange.Value;
                    if (status != null)
                    {
                        if (key.EndsWith("_WorkshopDate"))
                        {
                            if (DateTime.TryParse(status.ToString(), out DateTime date))
                            {
                                var workshopDate = date.ToString("MM/dd/yyyy");
                                var task = new RoadmapTask
                                {
                                    Id = key,
                                    Status = workshopDate
                                };
                                roadmapList.Add(task);
                            }
                        }
                        else
                        {
                            RoadmapTask task = GetRoadmapTask(name, key, range, status);
                            roadmapList.Add(task);
                        }
                    };
                }
            }
        }
        return roadmap;
    }

    private static RoadmapTask GetRoadmapTask(IName? name, string key, IRange range, string status)
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
            task.Title = titleRange.Value;
            if (titleRange.Comment != null) task.Description = titleRange.Comment.Text;
        }
        catch { }

        return task;
    }

    public async Task ConvertToWorkbookAsync(Roadmap roadmap)
    {
        var roadmapList = roadmap.Identity;
        roadmapList.AddRange(roadmap.Device);
        roadmapList.AddRange(roadmap.DevSecOps);
        roadmapList.AddRange(roadmap.Data);


        ClearHeaders();

        foreach (var item in roadmapList)
        {
            var key = item.Id;
            var status = Labels.ConvertStatusStringToLabel(item.Status);
            try
            {
                var range = _workbook.Names[key].RefersToRange;
                range.Value = status;
            }
            catch { }
        }

        RemoveNonRoadmapSheets();
    }

    /// <summary>
    /// We don't need other worksheets when generated from ADO data
    /// </summary>
    private void RemoveNonRoadmapSheets()
    {
        for (int i = _workbook.Worksheets.Count - 1; i >= 0; i--)
        {
            var sheet = _workbook.Worksheets[i];
            var range = GetRange(sheet, SheetNameRangeName);
            if (range != null)
            {
                if (range.Value.StartsWith("Workshop"))
                {
                    _workbook.Worksheets.Remove(i);
                }
            }
        }
    }

    /// <summary>
    /// Workbook versions
    /// There can be two versions of the workbook.
    /// v1. Pre 2024-Mar-06: The sheet access was index based (0=Home, etc)
    /// v2. Post 2024-Mar-06: The sheet access is based on the value of a range (SheetName -usually A1) in each sheet.
    ///     The value of range SheetName will match the name of the enum ZtSheets
    ///     Going forward if sheets are added, removed or moved around, it will not affect the sheet access mechanism.
    /// </summary>
    /// <param name="workbook"></param>
    /// <param name="sheet"></param>
    /// <returns></returns>
    public static IWorksheet GetWorksheet(IWorkbook workbook, ZtSheets sheet)
    {
        if (IsV2(workbook))
        {
            var sheetNameToFind = Enum.GetName(sheet);
            foreach (var worksheet in workbook.Worksheets)
            {
                var sheetName = worksheet.Range[SheetNameRangeName].Value;
                // Get the string of the enum ZtSheet for sheet
                if (sheetName == sheetNameToFind)
                {
                    return worksheet;
                }
            }
            throw new Exception($"Worksheet with SheetName range set to '{sheetNameToFind}' was not found.");
        }
        else
        { // Follow old style.
            return workbook.Worksheets[(int)sheet];
        }
    }

    private static bool IsV2(IWorkbook workbook)
    {
        bool hasVersionRange = false;
        foreach (var sheet in workbook.Worksheets)
        {
            var range = GetRange(sheet, "WorkbookVersion");
            if (range != null)
            {
                hasVersionRange = true;
                break;
            }
        }
        return hasVersionRange;
    }

    private static IRange? GetRange(IWorksheet sheet, string rangeName)
    {
        IRange? range = null;
        try
        {
            range = sheet.Range[rangeName];
        }
        catch { }
        return range;
    }

    /// Updates the images in the template and sets the link to point to the corresponding docs page.
    public void SetTemplateDocLinks()
    {

        var sbPics = new StringBuilder();
        var sheetIdentity = GetWorksheet(_workbook, ZtSheets.WorkshopIdentity);

        var picsList = sbPics.ToString();

        var sbRanges = new StringBuilder();
        if (_workbook.Names is WorkbookNamesCollection names)
        {
            foreach (var name in names)
            {
                var key = name.Name;

                if (key.StartsWith("R") && key.Contains("_")) //Look for image if it is a valid roadmap item
                {
                    var range = name.RefersToRange;
                    sbRanges.AppendLine($"{range.AddressR1C1},{range.Row},{range.Column},{range.Value}");
                    range.Value = "✜ In planning";
                }
            }
        }
        var rangesList = sbRanges.ToString();
    }
}
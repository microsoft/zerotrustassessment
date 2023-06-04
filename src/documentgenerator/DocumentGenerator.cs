using ZeroTrustAssessment.DocumentGenerator.Graph;
using System.Reflection;
using Syncfusion.XlsIO;

namespace ZeroTrustAssessment.DocumentGenerator;

public class DocumentGenerator
{
    private GraphData _graphData = new ();

    #region GenerateDocument overloads
    public void GenerateDocument(GraphData graphData, Stream outputStream, ConfigOptions configOptions)
    {
        Stream templateStream = Assembly.GetExecutingAssembly().GetManifestResourceStream("ZeroTrustAssessment.DocumentGenerator.Assets.ZeroTrustTemplate.xlsx");

        IWorkbook workbook = OpenWorkbook(templateStream);

        GenerateDocument(graphData, workbook, outputStream, configOptions);
    }

    private static IWorkbook OpenWorkbook(Stream templateStream)
    {
        ExcelEngine excelEngine = GetExcelEngine();
        IWorkbook workbook = excelEngine.Excel.Workbooks.Open(templateStream);
        return workbook;
    }

    private static ExcelEngine GetExcelEngine()
    {
        ExcelEngine excelEngine = new ExcelEngine();
        IApplication application = excelEngine.Excel;
        application.DefaultVersion = ExcelVersion.Xlsx;
        return excelEngine;
    }

    public void GenerateDocument(GraphData graphData, Stream templateFile, Stream outputStream, ConfigOptions configOptions)
    {        
        IWorkbook pptxDoc = OpenWorkbook(templateFile);
        GenerateDocument(graphData, pptxDoc, outputStream, configOptions);
    }

    public void GenerateDocument(GraphData graphData, string templateFilePath, Stream outputStream, ConfigOptions configOptions)
    {
        ExcelEngine excelEngine = GetExcelEngine();
        FileStream inputStream = new FileStream(templateFilePath, FileMode.Open);
        IWorkbook workbook = OpenWorkbook(inputStream);
        GenerateDocument(graphData, workbook, outputStream, configOptions);
    }
    #endregion

    public void GenerateDocument(GraphData graphData, IWorkbook pptxDoc, Stream outputStream, ConfigOptions configOptions)
    {
        _graphData = graphData;

        SetDocHeaderInfo(pptxDoc.Worksheets[0]);

        pptxDoc.SaveAs(outputStream);

        pptxDoc.Close();
    } 

    private void SetDocHeaderInfo(IWorksheet sheet)
    {

        if (_graphData.Organization != null && _graphData.Organization.Count > 0)
        {
            var org = _graphData.Organization.First();
            sheet.Range["TenantId"].Text = org.Id;
            sheet.Range["TenantName"].Text = org.DisplayName;
            sheet.Range["AssessmentRunBy"].Text = $"{_graphData?.Me?.DisplayName} ({_graphData?.Me?.UserPrincipalName})";
            sheet.TextBoxes["txtIdentityStatus"].Text = "❌";
        }

        sheet.Range["AssessedOn"].Text = DateTime.Now.ToString("dd MMM yyyy");
    }
}

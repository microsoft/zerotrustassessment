using Syncfusion.XlsIO;
using System.Reflection;

namespace ZeroTrustAssessment.DocumentGenerator;

public class ExcelHelper
{
    public static IWorkbook OpenWorkbook(string resourceName)
    {
        Stream templateStream = Assembly.GetExecutingAssembly().GetManifestResourceStream(resourceName);
        return OpenWorkbook(templateStream);
    }

    public static IWorkbook OpenWorkbook(Stream templateStream)
    {
        ExcelEngine excelEngine = GetExcelEngine();
        IWorkbook workbook = excelEngine.Excel.Workbooks.Open(templateStream);
        templateStream.Dispose();
        return workbook;
    }

    public static ExcelEngine GetExcelEngine()
    {
        ExcelEngine excelEngine = new ExcelEngine();
        IApplication application = excelEngine.Excel;
        application.DefaultVersion = ExcelVersion.Xlsx;
        return excelEngine;
    }
}
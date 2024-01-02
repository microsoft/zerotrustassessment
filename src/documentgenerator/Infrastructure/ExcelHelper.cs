using Syncfusion.XlsIO;
using System.Reflection;

namespace ZeroTrustAssessment.DocumentGenerator.Infrastructure;

public class ExcelHelper
{
    public static IWorkbook OpenWorkbookFile(string filePath)
    {
        Stream templateStream = new FileStream(filePath, FileMode.Open, FileAccess.Read);
        return OpenWorkbook(templateStream);
    }

    public static IWorkbook OpenWorkbook(string resourceName)
    {
        Stream templateStream = Assembly.GetExecutingAssembly().GetManifestResourceStream(resourceName);
        return OpenWorkbook(templateStream);
    }

    public static IWorkbook OpenWorkbook(Stream templateStream)
    {
        ExcelEngine excelEngine = GetExcelEngine();
        IWorkbook workbook = excelEngine.Excel.Workbooks.Open(templateStream);
        //templateStream.Dispose();
        return workbook;
    }

    public static ExcelEngine GetExcelEngine()
    {
        ExcelEngine excelEngine = new();
        IApplication application = excelEngine.Excel;
        application.DefaultVersion = ExcelVersion.Xlsx;
        return excelEngine;
    }

    public static void SaveWorkbookFile(IWorkbook workbook, string filePath)
    {
        //Save the workbook to stream
        FileStream fileStream = new FileStream(filePath, FileMode.Create, FileAccess.Write);
        workbook.SaveAs(fileStream);
    }

}
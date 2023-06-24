using Syncfusion.XlsIO;
using ZeroTrustAssessment.DocumentGenerator.Graph;
using ZeroTrustAssessment.DocumentGenerator.Infrastructure;

namespace ZeroTrustAssessment.DocumentGenerator;

public class DocumentGenerator
{
    public void GenerateDocument(GraphData graphData, Stream outputStream, ConfigOptions configOptions)
    {
        IWorkbook workbook = ExcelHelper.OpenWorkbook("ZeroTrustAssessment.DocumentGenerator.Assets.ZeroTrustTemplate.xlsx");

        GenerateDocument(graphData, workbook, outputStream, configOptions);
    }

    public void GenerateDocument(GraphData graphData, Stream templateFile, Stream outputStream, ConfigOptions configOptions)
    {        
        IWorkbook pptxDoc = ExcelHelper.OpenWorkbook(templateFile);
        GenerateDocument(graphData, pptxDoc, outputStream, configOptions);
    }

    public void GenerateDocument(GraphData graphData, string templateFilePath, Stream outputStream, ConfigOptions configOptions)
    {
        FileStream inputStream = new FileStream(templateFilePath, FileMode.Open);
        IWorkbook workbook = ExcelHelper.OpenWorkbook(inputStream);
        GenerateDocument(graphData, workbook, outputStream, configOptions);
    }

    public void GenerateDocument(GraphData graphData, IWorkbook workbook, Stream outputStream, ConfigOptions configOptions)
    {
        var ztWorkbook = new ZtWorkbook(workbook, graphData);

        ztWorkbook.GenerateDocument();
        workbook.SaveAs(outputStream);
        workbook.Close();
    }
}

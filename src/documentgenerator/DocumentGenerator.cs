using Syncfusion.XlsIO;
using ZeroTrustAssessment.DocumentGenerator.Graph;
using ZeroTrustAssessment.DocumentGenerator.Infrastructure;

namespace ZeroTrustAssessment.DocumentGenerator;

public class DocumentGenerator
{
    public async Task GenerateDocumentAsync(GraphData graphData, IdPowerToys.PowerPointGenerator.Graph.GraphData pptxGraphData, Stream outputStream, ConfigOptions configOptions)
    {
        IWorkbook workbook = ExcelHelper.OpenWorkbook("ZeroTrustAssessment.DocumentGenerator.Assets.ZeroTrustTemplateAssessment.xlsx");

        await GenerateDocumentAsync(graphData, pptxGraphData, workbook, outputStream, configOptions);
    }

    public async Task GenerateDocumentAsync(GraphData graphData, IdPowerToys.PowerPointGenerator.Graph.GraphData pptxGraphData, Stream templateFile, Stream outputStream, ConfigOptions configOptions)
    {        
        IWorkbook pptxDoc = ExcelHelper.OpenWorkbook(templateFile);
        await GenerateDocumentAsync(graphData, pptxGraphData, pptxDoc, outputStream, configOptions);
    }

    public async Task GenerateDocumentAsync(GraphData graphData, IdPowerToys.PowerPointGenerator.Graph.GraphData pptxGraphData, string templateFilePath, Stream outputStream, ConfigOptions configOptions)
    {
        FileStream inputStream = new FileStream(templateFilePath, FileMode.Open);
        IWorkbook workbook = ExcelHelper.OpenWorkbook(inputStream);
        await GenerateDocumentAsync(graphData, pptxGraphData, workbook, outputStream, configOptions);
    }

    public async Task GenerateDocumentAsync(GraphData graphData, IdPowerToys.PowerPointGenerator.Graph.GraphData pptxGraphData, IWorkbook workbook, Stream outputStream, ConfigOptions configOptions)
    {
        var ztWorkbook = new ZtWorkbook(workbook, graphData);

        await ztWorkbook.GenerateDocumentAsync(pptxGraphData);
        workbook.SaveAs(outputStream);
        workbook.Close();
    }
}

using Syncfusion.XlsIO;
using ZeroTrustAssessment.DocumentGenerator.Graph;
using ZeroTrustAssessment.DocumentGenerator.Infrastructure;

namespace ZeroTrustAssessment.DocumentGenerator
{
    public class DocumentGenerator
    {
        public async Task GenerateDocumentAsync(GraphData graphData, Stream outputStream, ConfigOptions configOptions)
        {
            IWorkbook workbook = ExcelHelper.OpenWorkbook("ZeroTrustAssessment.DocumentGenerator.Assets.ZeroTrustTemplate.xlsx");

            await GenerateDocumentAsync(graphData, workbook, outputStream, configOptions);
        }

        public async Task GenerateDocumentAsync(GraphData graphData, Stream templateFile, Stream outputStream, ConfigOptions configOptions)
        {
            IWorkbook pptxDoc = ExcelHelper.OpenWorkbook(templateFile);
            await GenerateDocumentAsync(graphData, pptxDoc, outputStream, configOptions);
        }

        public async Task GenerateDocumentAsync(GraphData graphData, string templateFilePath, Stream outputStream, ConfigOptions configOptions)
        {
            FileStream inputStream = new FileStream(templateFilePath, FileMode.Open);
            IWorkbook workbook = ExcelHelper.OpenWorkbook(inputStream);
            await GenerateDocumentAsync(graphData, workbook, outputStream, configOptions);
        }

        public async Task GenerateDocumentAsync(GraphData graphData, IWorkbook workbook, Stream outputStream, ConfigOptions configOptions)
        {
            var ztWorkbook = new ZtWorkbook(workbook, graphData);

            await ztWorkbook.GenerateDocumentAsync();
            workbook.SaveAs(outputStream);
            workbook.Close();
        }
    }
}

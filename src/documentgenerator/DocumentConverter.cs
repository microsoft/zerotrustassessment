using Syncfusion.XlsIO;
using ZeroTrustAssessment.DocumentGenerator.Infrastructure;
using ZeroTrustAssessment.DocumentGenerator.ViewModels.Convert;

namespace ZeroTrustAssessment.DocumentGenerator;

public class DocumentConverter
{
    public async Task<Roadmap> ConvertDocumentAsync(Stream documentStream)
    {
        IWorkbook workbook = ExcelHelper.OpenWorkbook(documentStream);

        var ztWorkbook = new ZtWorkbook(workbook);

        var roadmap = await ztWorkbook.ConvertToJsonAsync();
        return roadmap;
    }
}
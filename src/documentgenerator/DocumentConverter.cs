using Syncfusion.XlsIO;
using ZeroTrustAssessment.DocumentGenerator.Infrastructure;
using ZeroTrustAssessment.DocumentGenerator.ViewModels.Convert;

namespace ZeroTrustAssessment.DocumentGenerator;

public class DocumentConverter
{
    public async Task<Roadmap> GetRoadmapAsync(Stream documentStream)
    {
        IWorkbook workbook = ExcelHelper.OpenWorkbook(documentStream);

        var ztWorkbook = new ZtWorkbook(workbook);

        var roadmap = await ztWorkbook.GetRoadmapAsync();
        return roadmap;
    }

    public async Task GenerateRoadmapWorkbookAsync(Roadmap roadmap, Stream outputStream)
    {
        IWorkbook workbook = ExcelHelper.OpenWorkbook("ZeroTrustAssessment.DocumentGenerator.Assets.ZeroTrustTemplate.xlsx");

        var ztWorkbook = new ZtWorkbook(workbook);

        await ztWorkbook.ConvertToWorkbookAsync(roadmap);
        workbook.SaveAs(outputStream);
        workbook.Close();
    }
}
using ZeroTrustAssessment.DocumentGenerator;
using Microsoft.AspNetCore.Mvc;
using ZeroTrustAssessment.DocumentGenerator.ViewModels.Convert;

namespace webapi.Controllers;

[ApiController]
[Route("[controller]")]
public class ConvertController : ControllerBase
{
    private readonly ILogger<ConvertController> _logger;

    public ConvertController(ILogger<ConvertController> logger)
    {
        _logger = logger;
    }

    [HttpPost("[action]")]
    public async Task<ActionResult<Roadmap>> ToJson(IFormFile file)
    {
        try
        {
            _logger.LogInformation("PostToJson");

            if (file == null)
            {
                _logger.LogError("File not found.");
                return BadRequest("File not found. Upload a file and try again.");
            }
            else
            {
                var converter = new DocumentConverter();
                var roadmap = await converter.GetRoadmapAsync(file.OpenReadStream());

                return roadmap;
            }
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "Conversion error");
            throw;
        }
    }

    [HttpPost("[action]")]
    public async Task<ActionResult<Roadmap>> ToWorkbook(Roadmap roadmap)
    {
        try
        {
            _logger.LogInformation("ToWorkbook");

            if (roadmap == null)
            {
                _logger.LogError("Roadmap not provided.");
                return BadRequest("Roadmap not provided.");
            }
            else
            {
                var converter = new DocumentConverter();
                var stream = new MemoryStream();
                await converter.GenerateRoadmapWorkbookAsync(roadmap, stream);
                _logger.LogInformation("GenerateRoadmapWorkbookAsync Complete");

                stream.Position = 0;

                Response.Clear();
                Response.ContentType = "application/octet-stream";
                Response.Headers.Add("Content-Disposition", "attachment; filename=\"ztassess.xlsx\"");
                return File(stream, "application/octet-stream", "ztassess.xlsx");
            }
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "Conversion error");
            throw;
        }
    }
}
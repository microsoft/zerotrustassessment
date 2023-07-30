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
                var roadmap = await converter.ConvertDocumentAsync(file.OpenReadStream());

                // var roadmap = new Roadmap();
                // roadmap.TenantId = "12345678-1234-1234-1234-123456789012";
                return roadmap;
            }
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "Conversion error");
            throw;
        }
    }
}

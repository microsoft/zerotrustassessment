using ZeroTrustAssessment.DocumentGenerator;
using ZeroTrustAssessment.DocumentGenerator.Graph;
using Microsoft.AspNetCore.Mvc;
using Microsoft.Extensions.Primitives;
using Microsoft.Graph.Beta.Models;

namespace webapi.Controllers;

[ApiController]
[Route("[controller]")]
public class DocumentController : ControllerBase
{
    private readonly ILogger<DocumentController> _logger;

    public DocumentController(ILogger<DocumentController> logger)
    {
        _logger = logger;
    }

    [HttpPost]
    public async Task<IActionResult> Post(ConfigOptions configOptions)
    {
        try
        {
            _logger.LogInformation("DocumentGeneration");
            var token = GetAccessTokenFromHeader();

            if(token == null)
            {
                throw new Exception("Token not found. Sign in and try again.");
            }
            var graphData = new GraphData(configOptions, token);

            await graphData.CollectData();

            Response.Clear();
            //Generate and stream doc
            Response.ContentType = "application/octet-stream";
            Response.Headers.Add("Content-Disposition", "attachment; filename=\"Zero Trust Assessment.xlsx\"");

            var gen = new DocumentGenerator();
            var stream = new MemoryStream();
            _logger.LogInformation("GenerateDocument");
            gen.GenerateDocument(graphData, stream, configOptions);

            stream.Position = 0;
            _logger.LogInformation("ReturnFile");
            return File(stream, "application/octet-stream", "ztassess.xlsx");
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "Assessment error");
            throw;
        }
    }

    private string? GetAccessTokenFromHeader()
    {
        Request.Headers.TryGetValue("X-DocumentGeneration-Token", out StringValues accessToken);
        var token = accessToken.FirstOrDefault();
        return token;
    }
}

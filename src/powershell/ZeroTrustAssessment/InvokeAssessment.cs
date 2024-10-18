using System;
using System.IO;
using System.Management.Automation;
using Gen = ZeroTrustAssessment.DocumentGenerator;
using ZeroTrustAssessment.DocumentGenerator.Graph;
using Microsoft.Identity.Client;
using System.Threading.Tasks;
using System.Linq;
using Microsoft.ApplicationInsights;
using Microsoft.ApplicationInsights.Extensibility;

namespace ZeroTrustAssessment;

[Cmdlet("Invoke", $"{Consts.ModulePrefix}Assessment", DefaultParameterSetName = "Default")]
public class InvokeAssessment : PSCmdlet
{
    const string GraphPowershellClientId = "14d82eec-204b-4c2f-b7e8-296a70dab67e";
    private TelemetryClient _telemetryClient;

    [Parameter(
        HelpMessage = "Output folder for the generated assessment. If not provided, the current directory will be used.",
        Position = 0,
        Mandatory = false,
        ValueFromPipeline = true,
        ParameterSetName = "Default",
        ValueFromPipelineByPropertyName = true)]
    [ValidateNotNullOrEmpty()]
    public string OutputFolder { get; set; }

    [Parameter(
        HelpMessage = "Access token to use for the assessment. If not provided, the user will be prompted to sign in.",
        Mandatory = true,
        ParameterSetName = "AccessToken",
        ValueFromPipelineByPropertyName = true)]
    public string AccessToken { get; set; }

    [Parameter(
        HelpMessage = "Client ID of a custom app created to run this assessment.",
        ParameterSetName = "CustomApp",
        Mandatory = true,
        ValueFromPipelineByPropertyName = true)]
    public string ClientId { get; set; }

    [Parameter(
        HelpMessage = "Tenant ID to use for the assessment.",
        ParameterSetName = "CustomApp",
        Mandatory = true,
        ValueFromPipelineByPropertyName = true)]
    public string TenantId { get; set; }

    [Parameter(
        HelpMessage = "Enable telemetry to be collected (tenant id collected). Defaults to true.",
        ParameterSetName = "Default",
        Mandatory = false,
        ValueFromPipelineByPropertyName = true)]
    [Parameter(
        HelpMessage = "Enable telemetry to be collected (tenant id collected). Defaults to true.",
        ParameterSetName = "AccessToken",
        Mandatory = false,
        ValueFromPipelineByPropertyName = true)]
    [Parameter(
        HelpMessage = "Enable telemetry to be collected (tenant id collected). Defaults to true.",
        ParameterSetName = "CustomApp",
        Mandatory = false,
        ValueFromPipelineByPropertyName = true)]
    public bool EnableTelemetry { get; set; } = true;

    // This method gets called once for each cmdlet in the pipeline when the pipeline starts executing
    protected override void BeginProcessing()
    {
        Syncfusion.Licensing.SyncfusionLicenseProvider.RegisterLicense(Consts.SfKey);

        if (EnableTelemetry)
        {
            var telemetryConfig = TelemetryConfiguration.CreateDefault();
            telemetryConfig.InstrumentationKey = Consts.InstrumentationKey;
            _telemetryClient = new TelemetryClient(telemetryConfig);
        }
    }

    // This method will be called for each input received from the pipeline to this cmdlet; if no input is received, this method is not called
    protected override void ProcessRecord()
    {
        if (string.IsNullOrEmpty(OutputFolder))
        {
            OutputFolder = SessionState.Path.CurrentLocation.Path;
        }
        if (string.IsNullOrEmpty(AccessToken))
        {
            if (string.IsNullOrEmpty(ClientId)) { ClientId = GraphPowershellClientId; }

            var app = new PublicClientApplicationOptions
            {
                AzureCloudInstance = AzureCloudInstance.AzurePublic,
                ClientId = ClientId,
                RedirectUri = "http://localhost",
                AadAuthorityAudience = AadAuthorityAudience.None
            };
            if (!string.IsNullOrEmpty(TenantId))
            {
                app.TenantId = TenantId;
            }

            var scopes = new[] {"Agreement.Read.All", "CrossTenantInformation.ReadBasic.All", "Directory.Read.All", "Policy.Read.All", "User.Read", "DeviceManagementServiceConfig.Read.All",
            "DeviceManagementConfiguration.Read.All", "DeviceManagementRBAC.Read.All", "DeviceManagementConfiguration.Read.All", "DeviceManagementApps.Read.All",
            "RoleAssignmentSchedule.Read.Directory","RoleEligibilitySchedule.Read.Directory", "PrivilegedEligibilitySchedule.Read.AzureADGroup" };

            AccessToken = SignInUserAndGetTokenUsingMsal(app, scopes).GetAwaiter().GetResult();
        }

        WriteInformation($"Running Zero Trust assessment. Please wait...", Consts.WriteInformationTagHost);
        var configOptions = new Gen.ConfigOptions();
        var graphData = new GraphData(configOptions, AccessToken, _telemetryClient);
        graphData.CollectData().GetAwaiter().GetResult();

        var pptxConfigOptions = new IdPowerToys.PowerPointGenerator.ConfigOptions
        {
            GroupSlidesByState = true
        };
        var pptxGraphData = new IdPowerToys.PowerPointGenerator.Graph.GraphData(pptxConfigOptions, AccessToken);
        pptxGraphData.CollectData().GetAwaiter().GetResult();

        var gen = new Gen.DocumentGenerator();

        if (!Path.Exists(OutputFolder))
        {
            Directory.CreateDirectory(OutputFolder);
        }

        var timestamp = DateTime.Now.ToString("yyyy-MM-ddTHHmmss");
        var saveFilePath = Path.Combine(OutputFolder, $@"ZeroTrustAssessment-{timestamp}.xlsx");
        using (var stream = new FileStream(saveFilePath, FileMode.Create))
        {
            gen.GenerateDocumentAsync(graphData, pptxGraphData, stream, configOptions).GetAwaiter().GetResult();
            stream.Position = 0;
        }
        WriteInformation($"Assessment completed.", Consts.WriteInformationTagHost);
        WriteInformation($"View assessment results {saveFilePath}", Consts.WriteInformationTagHost);
    }

    // This method will be called once at the end of pipeline execution; if no input is received, this method is not called
    protected override void EndProcessing()
    {
        WriteVerbose("End!");
    }

    private static async Task<string> SignInUserAndGetTokenUsingMsal(PublicClientApplicationOptions configuration, string[] scopes)
    {


        // // Initialize the MSAL library by building a public client application
        // var applicationBuilder = PublicClientApplicationBuilder.Create(configuration.ClientId)
        //                                         .WithDefaultRedirectUri();

        // if(!string.IsNullOrEmpty(configuration.TenantId))
        // {
        //     string authority = string.Concat(configuration.Instance, configuration.TenantId);
        //     applicationBuilder = applicationBuilder.WithAuthority(authority);
        // }
        // var application = applicationBuilder.Build();

        var application = PublicClientApplicationBuilder.CreateWithApplicationOptions(configuration).Build();

        AuthenticationResult result;
        try
        {
            var accounts = await application.GetAccountsAsync();
            result = await application.AcquireTokenSilent(scopes, accounts.FirstOrDefault())
             .ExecuteAsync();
        }
        catch (MsalUiRequiredException ex)
        {
            result = await application.AcquireTokenInteractive(scopes)
             .WithClaims(ex.Claims)
             .ExecuteAsync();
        }

        return result.AccessToken;
    }
}

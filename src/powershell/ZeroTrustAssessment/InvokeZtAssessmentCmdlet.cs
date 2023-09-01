using System;
using System.IO;
using System.Management.Automation;
using Gen = ZeroTrustAssessment.DocumentGenerator;
using ZeroTrustAssessment.DocumentGenerator.Graph;
using Microsoft.Identity.Client;
using System.Threading.Tasks;
using System.Linq;

namespace ZeroTrustAssessment;

[Cmdlet("Invoke", $"{Consts.ModulePrefix}Assessment")]
[CmdletBinding(DefaultParameterSetName = "Default")]
public class InvokeZtAssessmentCmdletCommand : PSCmdlet
{
    const string GraphPowershellClientId = "14d82eec-204b-4c2f-b7e8-296a70dab67e";

    [Parameter(
        HelpMessage = "Output folder for the generated assessment",
        ParameterSetName = "Default",
        Mandatory = true,
        Position = 0,
        ValueFromPipeline = true,
        ValueFromPipelineByPropertyName = true)]
    [Parameter (ParameterSetName = "AccessToken", Mandatory = true)]
    [Parameter (ParameterSetName = "ClientId", Mandatory = true)]
    public string OutputFolder { get; set; }

    [Parameter(
        HelpMessage = "Access token to use for the assessment. If not provided, the user will be prompted to sign in.",
        Mandatory = true,
        ParameterSetName = "AccessToken",
        ValueFromPipelineByPropertyName = true)]
    public string AccessToken { get; set; }

    [Parameter(
        HelpMessage = "Client ID of a custom app created to run this assessment.",
        ParameterSetName = "ClientId",
        Mandatory = true,
        ValueFromPipelineByPropertyName = true)]
    public string ClientId { get; set; }

    [Parameter(
        HelpMessage = "Tenant ID to use for the assessment.",
        ParameterSetName = "ClientId",
        Mandatory = true,
        ValueFromPipelineByPropertyName = true)]
    public string TenantId { get; set; }
    // This method gets called once for each cmdlet in the pipeline when the pipeline starts executing
    protected override void BeginProcessing()
    {
        Syncfusion.Licensing.SyncfusionLicenseProvider.RegisterLicense(Consts.SfKey);
    }

    // This method will be called for each input received from the pipeline to this cmdlet; if no input is received, this method is not called
    protected override void ProcessRecord()
    {
        if (string.IsNullOrEmpty(AccessToken))
        {
            
            var app = new PublicClientApplicationOptions();
            app.AzureCloudInstance = AzureCloudInstance.AzurePublic;
            app.ClientId = GraphPowershellClientId;
            app.RedirectUri = "http://localhost";
            if(!string.IsNullOrEmpty(ClientId))
            {
                app.ClientId = ClientId;
                app.TenantId = TenantId;
                app.AzureCloudInstance = AzureCloudInstance.AzurePublic;
            }
            app.AadAuthorityAudience = AadAuthorityAudience.None;
            var scopes = new[] {"Agreement.Read.All", "CrossTenantInformation.ReadBasic.All", "Directory.Read.All", "Policy.Read.All", "User.Read", "DeviceManagementServiceConfig.Read.All",
            "DeviceManagementConfiguration.Read.All", "DeviceManagementRBAC.Read.All", "DeviceManagementConfiguration.Read.All", "DeviceManagementApps.Read.All",
            "RoleAssignmentSchedule.Read.Directory","RoleEligibilitySchedule.Read.Directory", "PrivilegedEligibilitySchedule.Read.AzureADGroup" };

            AccessToken = SignInUserAndGetTokenUsingMSAL(app, scopes).GetAwaiter().GetResult();
        }

        WriteInformation($"Running Zero Trust assessment. Please wait...", Consts.WriteInformationTagHost);
        var configOptions = new Gen.ConfigOptions();
        var graphData = new GraphData(configOptions, AccessToken);
        graphData.CollectData().GetAwaiter().GetResult();

        var pptxConfigOptions = new IdPowerToys.PowerPointGenerator.ConfigOptions
        {
            GroupSlidesByState = true
        };
        var pptxGraphData = new IdPowerToys.PowerPointGenerator.Graph.GraphData(pptxConfigOptions, AccessToken);
        pptxGraphData.CollectData().GetAwaiter().GetResult();

        var gen = new Gen.DocumentGenerator();

        if(!Path.Exists(OutputFolder))
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

    private static async Task<string> SignInUserAndGetTokenUsingMSAL(PublicClientApplicationOptions configuration, string[] scopes)
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

using System.Collections.Specialized;
using ZeroTrustAssessment.DocumentGenerator.Infrastructure;
using Microsoft.Graph;
using Microsoft.Graph.Beta;
using System.Net.Http.Headers;

namespace ZeroTrustAssessment.DocumentGenerator.Graph;

public class GraphHelper
{
    GraphServiceClient _graph;
    public GraphServiceClient GraphServiceClient { get { return _graph; } }

    public GraphHelper(GraphServiceClient graphServiceClient)
    {
        _graph = graphServiceClient;
    }

    public async Task<User?> GetMe()
    {
        try
        {
            var me = await _graph.Me.GetAsync();
            return me;
        }
        catch { return null; }
    }


    public async Task<List<Organization>?> GetOrganization()
    {
        try
        {
            var org = await _graph.Organization.GetAsync();
            return org?.Value;
        }
        catch { return null; }
    }

    public async Task<Stream?> GetOrganizationBannerImage(string tenantId)
    {
        try
        {

            // using(var httpClient = new HttpClient())
            // {
            //     string ApiUrl = $"https://graph.microsoft.com/v1.0/organization/{tenantId}/branding/localizations/default/bannerLogo";
            //     httpClient.DefaultRequestHeaders.Authorization = new AuthenticationHeaderValue("Bearer", _graph.);
            //     response = await httpClient.GetFromJsonAsync<RedeemResponse>(ApiUrl);
            //     response.ProdId = prodid;
            // }

            var bannerLogo = await _graph.Organization[tenantId].Branding.Localizations["0"].BannerLogo.GetAsync();
            return bannerLogo;
        }
        catch (Exception ex) { System.Console.WriteLine(ex.Message); return null; }
    }

    public async Task<string?> GetTenantName(string tenantId)
    {
        try
        {
            var tenantInfo = await _graph.TenantRelationships.FindTenantInformationByTenantIdWithTenantId(tenantId).GetAsync();
            return tenantInfo?.DisplayName;
        }
        catch { return null; }
    }

}
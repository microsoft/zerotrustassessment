using System.Collections.Specialized;
using ZeroTrustAssessment.DocumentGenerator.Infrastructure;
using Microsoft.Graph;
using Microsoft.Graph.Beta;

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
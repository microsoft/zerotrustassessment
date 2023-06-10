using Microsoft.Graph.Beta.Drives.Item.Items.Item.Workbook.Functions.Var_P;

namespace ZeroTrustAssessment.DocumentGenerator.Graph;

public class GraphHelper
{
    readonly GraphServiceClient _graph;
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
            Task<MobilityManagementPolicyCollectionResponse?> x = _graph.Policies.MobileDeviceManagementPolicies.GetAsync();
            return org?.Value;
        }
        catch { return null; }
    }

    public async Task<Stream?> GetOrganizationBannerImage(string tenantId)
    {
        try
        {
            var bannerLogo = await _graph.Organization[tenantId].Branding.Localizations["0"].BannerLogo.GetAsync();
            return bannerLogo;
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

    public async Task<List<MobilityManagementPolicy>?> GetMobileDeviceManagementPolicies()
    {
        try
        {
            var result = await _graph.Policies.MobileDeviceManagementPolicies.GetAsync((requestConfiguration) =>
            {
	            requestConfiguration.QueryParameters.Expand = new string []{ "includedGroups" };
            });
            return result?.Value;
        }
        catch { return null; }
    }

    public async Task<List<DeviceEnrollmentConfiguration>?> GetDeviceEnrollmentConfigurations()
    {
        try
        {
            var result = await _graph.DeviceManagement.DeviceEnrollmentConfigurations.GetAsync((requestConfiguration) =>
            {
	            requestConfiguration.QueryParameters.Expand = new string []{ "assignments" };
            });
            return result?.Value;
        }
        catch { return null; }
    }

    public async Task<Group?> GetGroup(string groupId)
    {
        try
        {
            var result = await _graph.Groups[groupId].GetAsync();
            return result;
        }
        catch { return null; }
    }

    public async Task<DeviceAndAppManagementAssignmentFilter?> GetDeviceManagementAssignmentFilter(string filterId)
    {
        try
        {
            var result = await _graph.DeviceManagement.AssignmentFilters[filterId].GetAsync();
            return result;
        }
        catch { return null; }
    }

    public async Task<List<RoleScopeTag>?> GetRoleScopeTags()
    {
        try
        {
            var result = await _graph.DeviceManagement.RoleScopeTags.GetAsync();
            return result.Value;
        }
        catch { return null; } 
    }
}
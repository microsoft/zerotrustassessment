using System.Text.Json;
using Microsoft.Kiota.Serialization.Json;

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
                requestConfiguration.QueryParameters.Expand = new string[] { "includedGroups" };
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
                requestConfiguration.QueryParameters.Expand = new string[] { "assignments" };
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
            return result?.Value;
        }
        catch { return null; }
    }

    public async Task<List<DeviceCompliancePolicy>?> GetDeviceCompliancePolicies()
    {
        try
        {
            var result = await _graph.DeviceManagement.DeviceCompliancePolicies.GetAsync((requestConfiguration) =>
            {
                requestConfiguration.QueryParameters.Expand = new string[] { "assignments", "scheduledActionsForRule($expand=scheduledActionConfigurations)" };
            });
            return result?.Value;
        }
        catch { return null; }
    }

    public async Task<List<AndroidManagedAppProtection>?> GetManagedAppPoliciesAndroid()
    {
        try
        {
            var result = await _graph.DeviceAppManagement.AndroidManagedAppProtections.GetAsync((requestConfiguration) =>
            {
                requestConfiguration.QueryParameters.Expand = new string[] { "assignments", "apps", "deploymentSummary" };
            });
            return result?.Value;
        }
        catch { return null; }
    }

    public async Task<List<IosManagedAppProtection>?> GetManagedAppPoliciesIos()
    {
        try
        {
            var result = await _graph.DeviceAppManagement.IosManagedAppProtections.GetAsync((requestConfiguration) =>
            {
                requestConfiguration.QueryParameters.Expand = new string[] { "assignments", "apps", "deploymentSummary" };
            });
            return result?.Value;
        }
        catch { return null; }
    }

    public async Task<List<MdmWindowsInformationProtectionPolicy>?> GetManagedAppPoliciesWindows()
    {
        try
        {
            var result = await _graph.DeviceAppManagement.MdmWindowsInformationProtectionPolicies.GetAsync((requestConfiguration) =>
            {
                requestConfiguration.QueryParameters.Expand = new string[] { "assignments", "protectedAppLockerFiles", "exemptAppLockerFiles" };
            });
            return result?.Value;
        }
        catch { return null; }
    }

    public async Task<GraphManagedAppStatusRaw?> GetManagedAppStatuses()
    {
        GraphManagedAppStatusRaw? result = null;
        try
        {
            var statusRaw = (ManagedAppStatusRaw?)await _graph.DeviceAppManagement.ManagedAppStatuses["managedAppList"].GetAsync();

            var seralizer = new JsonSerializationWriter();
            seralizer.WriteObjectValue(string.Empty, statusRaw);
            var serializedContent = seralizer.GetSerializedContent();
            string jsonx = string.Empty;
            using (var sr = new StreamReader(serializedContent))
            {
                jsonx = sr.ReadToEnd();
            }

            if (!string.IsNullOrEmpty(jsonx))
            {
                result = JsonSerializer.Deserialize<GraphManagedAppStatusRaw>(jsonx);
            }


            return result;
        }
        catch { return null; }
    }

    public async Task<List<DeviceConfiguration>?> GetDeviceConfigurations()
    {
        try
        {
            var result = await _graph.DeviceManagement.DeviceConfigurations.GetAsync((requestConfiguration) =>
            {
                requestConfiguration.QueryParameters.Expand = new string[] { "assignments" };
            });
            return result?.Value;
        }
        catch { return null; }
    }

    public async Task<List<ConditionalAccessPolicy>?> GetConditionalAccessPolicies()
    {
        try
        {
            var result = await _graph.Identity.ConditionalAccess.Policies.GetAsync();
            return result?.Value;
        }
        catch { return null; }
    }

    public async Task<TenantAppManagementPolicy?> GetTenantAppManagementPolicy()
    {
        try
        {
            var result = await _graph.Policies.DefaultAppManagementPolicy.GetAsync();
            return result;
        }
        catch { return null; }
    }
}
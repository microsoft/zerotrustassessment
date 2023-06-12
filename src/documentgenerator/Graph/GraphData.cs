using System.Collections.Specialized;
using Microsoft.Kiota.Abstractions.Authentication;
using ZeroTrustAssessment.DocumentGenerator.Infrastructure;

namespace ZeroTrustAssessment.DocumentGenerator.Graph;

public class GraphData
{
    private readonly GraphHelper _graphHelper;
    public StringDictionary? ObjectCache { get; set; }
    public User? Me { get; set; }
    public ConfigOptions? ConfigOptions { get; private set; }
    public Stream? OrganizationLogo { get; private set; }

    public ICollection<Organization>? Organization { get; private set; }
    public List<MobilityManagementPolicy>? MobilityManagementPolicies { get; private set; }
    public List<DeviceEnrollmentConfiguration>? DeviceEnrollmentConfigurations { get; private set; }
    public List<RoleScopeTag>? RoleScopeTags { get; set; }
    public List<DeviceCompliancePolicy>? DeviceCompliancePolicies { get; set; }

    public GraphData(ConfigOptions configOptions, string accessToken) //Web API call
    {
        ConfigOptions = configOptions;
        var graphClient = GetGraphClientUsingAccessToken(accessToken);
        _graphHelper = new GraphHelper(graphClient);
    }

    public GraphData(ConfigOptions configOptions, GraphHelper graphHelper) //Desktop/CLI app
    {
        ConfigOptions = configOptions;
        _graphHelper = graphHelper;
    }

    public async Task CollectData()
    {
        //TODO: Batch and call in parallel to improve perf
        Me = await _graphHelper.GetMe();
        Organization = await _graphHelper.GetOrganization();
        OrganizationLogo = await GetOrganizationLogo();
        MobilityManagementPolicies = await _graphHelper.GetMobileDeviceManagementPolicies();
        DeviceEnrollmentConfigurations = await _graphHelper.GetDeviceEnrollmentConfigurations();
        RoleScopeTags = await _graphHelper.GetRoleScopeTags();
        DeviceCompliancePolicies = await _graphHelper.GetDeviceCompliancePolicies();
    }

    private async Task<Stream?> GetOrganizationLogo()
    {
        var org = Organization?.FirstOrDefault();
        Stream? logo = null;
        if (org != null && org.Id != null)
        {
            logo = await _graphHelper.GetOrganizationBannerImage(org.Id);
        }
        return logo;
    }

    private GraphServiceClient GetGraphClientUsingAccessToken(string accessToken)
    {
        var tokenProvider = new TokenProvider();
        tokenProvider.AccessToken = accessToken;
        var accessTokenProvider = new BaseBearerTokenAuthenticationProvider(tokenProvider);

        var graphClient = new GraphServiceClient(accessTokenProvider, "https://graph.microsoft.com/beta");
        return graphClient;
    }

    internal string GetGroupName(string? groupId)
    { //TODO add caching
        if (groupId == null) return string.Empty;
        var group = _graphHelper.GetGroup(groupId).Result;
        if (group == null)
        {
            return "Deleted group";
        }
        else
        {
            return group.DisplayName ?? string.Empty;
        }
    }

    internal string GetGroupAssignmentFilterName(string filterId)
    { //TODO add caching
        var filter = _graphHelper.GetDeviceManagementAssignmentFilter(filterId).Result;
        if (filter == null)
        {
            return "Deleted filter";
        }
        else
        {
            return filter.DisplayName ?? string.Empty;
        }
    }

    internal string GetScopesString(List<string>? roleScopeTagIds)
    {
        var result = string.Empty;
        if (RoleScopeTags != null && roleScopeTagIds != null)
        {
            foreach (var id in roleScopeTagIds)
            {
                var tag = RoleScopeTags.FirstOrDefault(x => x.Id == id);
                if (tag != null)
                {
                    result += Helper.AppendWithComma(result, tag.DisplayName);
                }
            }
        }
        return result;
    }

    internal string GetGroupAssignmentTargetText(List<EnrollmentConfigurationAssignment>? assignments)
    {
        string text = string.Empty;
        if (assignments == null) return text;
        foreach (var assignment in assignments)
        {
            string? filterId = null;
            if (assignment.Target is AllLicensedUsersAssignmentTarget allUsers)
            {
                text = "All users";
                filterId = allUsers.DeviceAndAppManagementAssignmentFilterId;
            }
            else if (assignment.Target is GroupAssignmentTarget group)
            {
                text += Helper.AppendWithComma(text, GetGroupName(group.GroupId));
                filterId = group.DeviceAndAppManagementAssignmentFilterId;
            }
            text += GetAssignmentFilter(filterId);
        }
        return text;
    }

    internal void GetGroupAssignmentTargetText(List<DeviceCompliancePolicyAssignment>? assignments, out string includedGroups, out string excludedGroups)
    {
        var includedList = new List<string>();
        var excludedList = new List<string>();
        if (assignments != null && assignments.Count > 0)
        {
            foreach (var assignment in assignments)
            {
                string? filterId;
                if (assignment.Target is AllLicensedUsersAssignmentTarget allUsers)
                {
                    var text = "All users";
                    filterId = allUsers.DeviceAndAppManagementAssignmentFilterId;
                    text += GetAssignmentFilter(filterId);
                    includedList.Insert(0, text);
                }
                else if (assignment.Target is AllDevicesAssignmentTarget allDevices)
                {
                    var text = "All devices";
                    filterId = allDevices.DeviceAndAppManagementAssignmentFilterId;
                    text += GetAssignmentFilter(filterId);
                    includedList.Insert(0, text);
                }
                else if (assignment.Target is GroupAssignmentTarget group)
                {
                    var text = GetGroupName(group.GroupId);
                    filterId = group.DeviceAndAppManagementAssignmentFilterId;
                    text += GetAssignmentFilter(filterId);
                    includedList.Add(text);
                }
                else if (assignment.Target is ExclusionGroupAssignmentTarget excludedGroup)
                {
                    var text = GetGroupName(excludedGroup.GroupId);
                    filterId = excludedGroup.DeviceAndAppManagementAssignmentFilterId;
                    text += GetAssignmentFilter(filterId);
                    excludedList.Add(text);
                }
                else
                {
                    includedList.Add("Unknown target");
                }
            }
        }
        includedGroups = string.Join(", ", includedList);
        excludedGroups = string.Join(", ", excludedList);
    }

    private string GetAssignmentFilter(string? filterId)
    {
        if (filterId == null || filterId == "00000000-0000-0000-0000-000000000000") return string.Empty;
        return " (Filter: " + GetGroupAssignmentFilterName(filterId) + ")";
    }
}


public class TokenProvider : IAccessTokenProvider
{
    public string? AccessToken { get; set; }

    public Task<string> GetAuthorizationTokenAsync(Uri uri, Dictionary<string, object>? additionalAuthenticationContext = default,
        CancellationToken cancellationToken = default)
    {
        return Task.FromResult(AccessToken ?? string.Empty);
    }

#pragma warning disable CS8618 // Non-nullable field must contain a non-null value when exiting constructor. Supressing since this is part of interface.
    public AllowedHostsValidator AllowedHostsValidator { get; }
#pragma warning restore CS8618 // Non-nullable field must contain a non-null value when exiting constructor. 
}
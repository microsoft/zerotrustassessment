using System.Collections.Specialized;
using System.IO;
using System.Threading.Tasks;
using Microsoft.Kiota.Abstractions.Authentication;
using ZeroTrustAssessment.DocumentGenerator.Infrastructure;

namespace ZeroTrustAssessment.DocumentGenerator.Graph
{

    public class GraphData
    {
        private readonly GraphHelper _graphHelper;
        public string TenantId { get; set; }
        public string TenantName { get; set; }
        public StringDictionary? ObjectCache { get; set; }
        public User? Me { get; set; }
        public ConfigOptions? ConfigOptions { get; private set; }
        public Stream? OrganizationLogo { get; private set; }

        public ICollection<Organization>? Organization { get; private set; }
        public List<MobilityManagementPolicy>? MobilityManagementPolicies { get; private set; }
        public List<DeviceEnrollmentConfiguration>? DeviceEnrollmentConfigurations { get; private set; }
        public List<RoleScopeTag>? RoleScopeTags { get; set; }
        public List<DeviceCompliancePolicy>? DeviceCompliancePolicies { get; set; }
        public List<AndroidManagedAppProtection>? ManagedAppPoliciesAndroid { get; set; }
        public List<IosManagedAppProtection>? ManagedAppPoliciesIos { get; set; }
        public List<MdmWindowsInformationProtectionPolicy>? ManagedAppPoliciesWindows { get; set; }

        public Dictionary<string, AppList> ManagedAppStatusIos { get; set; } = new Dictionary<string, AppList>();
        public Dictionary<string, AppList> ManagedAppStatusAndroid { get; set; } = new Dictionary<string, AppList>();

        public List<DeviceConfiguration>? DeviceConfigurations { get; set; } = new List<DeviceConfiguration>();

        public List<ConditionalAccessPolicy> ConditionalAccessPolicies { get; set; } = new List<ConditionalAccessPolicy>();

        public TenantAppManagementPolicy? TenantAppManagementPolicy { get; set; }
        public List<UnifiedRoleAssignment> RoleAssignments { get; set; } = new List<UnifiedRoleAssignment>();
        public AuthenticationMethodsPolicy? AuthenticationMethodsPolicy { get; set; }

        public List<DirectorySettingTemplate> DirectorySettingTemplate { get; set; } = new List<DirectorySettingTemplate>();
        public List<DirectorySetting> DirectorySetting { get; set; } = new List<DirectorySetting>();

        public List<UnifiedRoleAssignmentSchedule> RoleAssignmentSchedule { get; set; } = new List<UnifiedRoleAssignmentSchedule>();
        public List<UnifiedRoleEligibilitySchedule> RoleEligibilitySchedule { get; set; } = new List<UnifiedRoleEligibilitySchedule>();

        public string Token { get; set; }

        public GraphData(ConfigOptions configOptions, string accessToken) //Web API call
        {
            Token = accessToken;
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
            ManagedAppPoliciesAndroid = await _graphHelper.GetManagedAppPoliciesAndroid();
            ManagedAppPoliciesIos = await _graphHelper.GetManagedAppPoliciesIos();
            ManagedAppPoliciesWindows = await _graphHelper.GetManagedAppPoliciesWindows();
            DeviceConfigurations = await _graphHelper.GetDeviceConfigurations();

            var conditionalAccessPolicies = await _graphHelper.GetConditionalAccessPolicies();
            if (conditionalAccessPolicies != null) ConditionalAccessPolicies = conditionalAccessPolicies;

            TenantAppManagementPolicy = await _graphHelper.GetTenantAppManagementPolicy();

            var assignments = await _graphHelper.GetRoleAssignments();
            if (assignments != null) RoleAssignments = assignments;

            AuthenticationMethodsPolicy = await _graphHelper.GetAuthenticationMethodsPolicy();

            var directorySettingTemplate = await _graphHelper.GetDirectorySettingTemplate();
            if (directorySettingTemplate != null) DirectorySettingTemplate = directorySettingTemplate;

            var directorySetting = await _graphHelper.GetDirectorySetting();
            if (directorySetting != null) DirectorySetting = directorySetting;

            var roleAssignmentSchedule = await _graphHelper.GetRoleAssignmentSchedules();
            if (roleAssignmentSchedule != null) RoleAssignmentSchedule = roleAssignmentSchedule;

            var roleEligibilitySchedule = await _graphHelper.GetRoleEligibilitySchedules();
            if (roleEligibilitySchedule != null) RoleEligibilitySchedule = roleEligibilitySchedule;

            LoadManagedAppStatuses();

            var org = Organization?.FirstOrDefault();
            if (org != null)
            {
                TenantId = org.Id;
                TenantName = org.DisplayName;
            }
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

        internal List<PrivilegedAccessGroupEligibilitySchedule>? GetPrivilegedAccessGroupEligibilitySchedule(string? groupId)
        { //TODO add caching
            if (groupId == null) return null;
            return _graphHelper.GetPrivilegedAccessGroupEligibilitySchedule(groupId).Result;
        }

        internal Group? GetGroup(string? groupId, bool expandMembers = false)
        { //TODO add caching
            if (groupId == null) return null;
            return _graphHelper.GetGroup(groupId, expandMembers).Result;
        }

        internal string GetGroupName(string? groupId)
        {
            var group = GetGroup(groupId);
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
                    else if (assignment.Target is ExclusionGroupAssignmentTarget excludedGroup)
                    {
                        var text = GetGroupName(excludedGroup.GroupId);
                        filterId = excludedGroup.DeviceAndAppManagementAssignmentFilterId;
                        text += GetAssignmentFilter(filterId);
                        excludedList.Add(text);
                    }
                    else if (assignment.Target is GroupAssignmentTarget group)
                    {
                        var text = GetGroupName(group.GroupId);
                        filterId = group.DeviceAndAppManagementAssignmentFilterId;
                        text += GetAssignmentFilter(filterId);
                        includedList.Add(text);
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

        internal void GetGroupAssignmentTargetText(List<TargetedManagedAppPolicyAssignment>? assignments, out string includedGroups, out string excludedGroups)
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
                    else if (assignment.Target is ExclusionGroupAssignmentTarget excludedGroup)
                    {
                        var text = GetGroupName(excludedGroup.GroupId);
                        filterId = excludedGroup.DeviceAndAppManagementAssignmentFilterId;
                        text += GetAssignmentFilter(filterId);
                        excludedList.Add(text);
                    }
                    else if (assignment.Target is GroupAssignmentTarget group)
                    {
                        var text = GetGroupName(group.GroupId);
                        filterId = group.DeviceAndAppManagementAssignmentFilterId;
                        text += GetAssignmentFilter(filterId);
                        includedList.Add(text);
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

        private async void LoadManagedAppStatuses()
        {
            var managedAppStatusRaw = await _graphHelper.GetManagedAppStatuses();
            if (managedAppStatusRaw?.Content.AppList.Length > 0)
            {
                foreach (var item in managedAppStatusRaw.Content.AppList)
                {
                    switch (item.AppIdentifier.OdataType)
                    {
                        case "#microsoft.graph.iosMobileAppIdentifier":
                            ManagedAppStatusIos.TryAdd(item.AppIdentifier.BundleId, item);
                            break;
                        case "#microsoft.graph.androidMobileAppIdentifier":
                            ManagedAppStatusAndroid.TryAdd(item.AppIdentifier.PackageId, item);
                            break;
                    }
                }
            }
        }

        /// <summary>
        /// Read default value then replace if there is a tenant specific value
        /// </summary>
        /// <returns></returns>
        public string? GetDirectorySetting(DirectorySettingTemplateEnum template, string settingName)
        {
            string? value = null;
            var templateItem = DirectorySettingTemplate.Where(x => x.Id == GetTemplateId(template)).FirstOrDefault();
            if (templateItem != null)
            {
                value = templateItem.Values?.Where(x => x.Name == settingName).FirstOrDefault()?.DefaultValue;

                var setting = DirectorySetting.Where(x => x.TemplateId == GetTemplateId(template)).FirstOrDefault();
                if (setting != null)
                {
                    var customValue = setting.Values?.Where(x => x.Name == settingName).FirstOrDefault()?.Value;
                    if (customValue != null)
                    {
                        value = customValue;
                    }
                }
            }
            return value;
        }

        public bool? GetDirectorySettingBool(DirectorySettingTemplateEnum template, string settingName)
        {
            var value = GetDirectorySetting(template, settingName);
            return bool.TryParse(value, out bool result) ? result : null;
        }
        public static string GetTemplateId(DirectorySettingTemplateEnum template)
        {
            return template switch
            {
                DirectorySettingTemplateEnum.Application => "4bc7f740-180e-4586-adb6-38b2e9024e6b",
                DirectorySettingTemplateEnum.ConsentPolicySettings => "dffd5d46-495d-40a9-8e21-954ff55e198a",
                DirectorySettingTemplateEnum.CustomPolicySettings => "898f1161-d651-43d1-805c-3b0b388a9fc2",
                DirectorySettingTemplateEnum.GroupUnified => "62375ab9-6b52-47ed-826b-58e47e0e304b",
                DirectorySettingTemplateEnum.GroupUnifiedGuest => "08d542b9-071f-4e16-94b0-74abb372e3d9",
                DirectorySettingTemplateEnum.PasswordRuleSettings => "5cf42378-d67d-4f36-ba46-e8b86229381d",
                DirectorySettingTemplateEnum.ProhibitedNamesSettings => "80661d51-be2f-4d46-9713-98a2fcaec5bc",
                DirectorySettingTemplateEnum.ProhibitedNamesRestrictedSettings => "aad3907d-1d1a-448b-b3ef-7bf7f63db63b",
                _ => string.Empty,
            };
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
}
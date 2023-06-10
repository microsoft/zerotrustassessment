using Syncfusion.XlsIO;
using ZeroTrustAssessment.DocumentGenerator.Graph;
using ZeroTrustAssessment.DocumentGenerator.Infrastructure;

namespace ZeroTrustAssessment.DocumentGenerator.Sheets;

public class SheetConfigDevice : SheetBase
{
    public SheetConfigDevice(IWorksheet sheet, GraphData graphData) : base(sheet, graphData)
    {
    }

    public void Generate()
    {
        MdmWindowsEnrollment();
        DeviceEnrollmentConfiguration();
    }

    private void MdmWindowsEnrollment()
    {
        if (_graphData.MobilityManagementPolicies == null)
        {
            SetValue("Table_WindowsEnrollment", "Not configured");
            return;
        }

        var startColumn = _sheet.Range["Table_WindowsEnrollment"].Column;
        var startRow = _sheet.Range["Table_WindowsEnrollment"].Row;

        var row = startRow;
        var rowCount = _graphData.MobilityManagementPolicies.Count;
        _sheet.InsertRow(startRow, rowCount);
        foreach (var policy in _graphData.MobilityManagementPolicies.OrderByDescending(x => x.AppliesTo).ThenBy(x => x.DisplayName))
        {
            _sheet.SetText(row, startColumn, "MDM");
            _sheet.SetText(row, startColumn + 1, policy.DisplayName);
            _sheet.SetText(row, startColumn + 6, GetAppliesToName(policy.AppliesTo));
            var groupName = policy.AppliesTo == PolicyScope.Selected && policy.IncludedGroups != null ?
                string.Join(", ", policy.IncludedGroups.Select(x => x.DisplayName)) : "N/A";
            _sheet.SetText(row, startColumn + 8, groupName);
            row++;
        }
    }

    private void DeviceEnrollmentConfiguration()
    {
        var platformRestrictions = _graphData.DeviceEnrollmentConfigurations?
            .Where(x => x.DeviceEnrollmentConfigurationType == DeviceEnrollmentConfigurationType.SinglePlatformRestriction)
            .OrderByDescending(x => x.Priority).ThenBy(x => x.DisplayName);

        var rowCount = (platformRestrictions?.Count() ?? 0) + 5;
        // if (rowCount == 0)
        // {
        //     SetValue("Table_EnrollmentDevicePlatformRestrictions", "Not configured");
        //     return;
        // }

        var startColumn = _sheet.Range["Table_EnrollmentDevicePlatformRestrictions"].Column;
        var startRow = _sheet.Range["Table_EnrollmentDevicePlatformRestrictions"].Row;

        var row = startRow;

        if (platformRestrictions != null)
        {
            var restrictions = new Dictionary<string, DeviceEnrollmentPlatformRestrictionConfiguration>();
            foreach (var config in platformRestrictions)
            {
                if (config is DeviceEnrollmentPlatformRestrictionConfiguration restriction) //First iterate and create list to make it easier to sort
                {
                    var sortKey = restriction.DisplayName + GetEnrollmentRestrictionPlatformTypeName(restriction.PlatformType) + restriction.Id;
                    restrictions.Add(sortKey, restriction);
                }
            }
            foreach (var item in restrictions.OrderBy(x => x.Key))
            {
                var restriction = item.Value;
                var platform = GetEnrollmentRestrictionPlatformTypeName(restriction.PlatformType);
                var priority = restriction.Priority;
                var displayName = restriction.DisplayName;
                var scopes = _graphData.GetScopesString(restriction.RoleScopeTagIds);
                var assignments = GetGroupAssignmentTargetText(restriction.Assignments);

                AddRow(row, startColumn, platform, priority, displayName, restriction.PlatformRestriction, scopes, assignments);

                row++;
            }
        }
        var defaultPlatformRestrictions = _graphData.DeviceEnrollmentConfigurations?
            .Where(x => x.DeviceEnrollmentConfigurationType == DeviceEnrollmentConfigurationType.PlatformRestrictions).FirstOrDefault();
        if (defaultPlatformRestrictions != null && defaultPlatformRestrictions is DeviceEnrollmentPlatformRestrictionsConfiguration defaultRestriction)
        {

            var platform = string.Empty;
            var priority = defaultRestriction.Priority;
            var displayName = "Default";
            var scopes = _graphData.GetScopesString(defaultRestriction.RoleScopeTagIds);
            var assignments = "All users and all devices";
            
            AddRow(row, startColumn, Labels.PlatformAndroidForWork, priority, displayName, defaultRestriction.AndroidForWorkRestriction, scopes, assignments); row++;
            AddRow(row, startColumn, Labels.PlatformAndroid, priority, displayName, defaultRestriction.AndroidRestriction, scopes, assignments); row++;
            AddRow(row, startColumn, Labels.PlatformIos, priority, displayName, defaultRestriction.IosRestriction, scopes, assignments); row++;
            AddRow(row, startColumn, Labels.PlatformMacOs, priority, displayName, defaultRestriction.MacOSRestriction, scopes, assignments); row++;
            AddRow(row, startColumn, Labels.PlatformWindows, priority, displayName, defaultRestriction.WindowsRestriction, scopes, assignments); row++;
        }

    }
    private void AddRow(int row, int startColumn, string platform, int? priority, string? displayName, DeviceEnrollmentPlatformRestriction? platformRestriction, string scopes, string assignments)
    {
        _sheet.SetText(row, startColumn, platform);
        _sheet.SetValue(row, startColumn + 3, $"{priority}");
        _sheet.SetText(row, startColumn + 4, displayName);

        if (platformRestriction != null)
        {
            _sheet.SetText(row, startColumn + 8, GetIsBlockedString(platformRestriction.PlatformBlocked));
            _sheet.SetText(row, startColumn + 9, GetString(platformRestriction.OsMinimumVersion));
            _sheet.SetText(row, startColumn + 10, GetString(platformRestriction.OsMaximumVersion));
            _sheet.SetText(row, startColumn + 11, GetIsBlockedString(platformRestriction.PersonalDeviceEnrollmentBlocked));
            _sheet.SetText(row, startColumn + 13, platformRestriction.BlockedManufacturers?.Count > 0 ? string.Join(", ", platformRestriction.BlockedManufacturers) : string.Empty);
            _sheet.SetText(row, startColumn + 15, scopes);
            _sheet.SetText(row, startColumn + 16, assignments);
        }
    }
    private string GetString(string? value)
    {
        return value ?? string.Empty;
    }
    private string GetGroupAssignmentTargetText(List<EnrollmentConfigurationAssignment>? assignments)
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
                if (text.Length > 0) text += ", ";
                text += _graphData.GetGroupName(group.GroupId);
                filterId = group.DeviceAndAppManagementAssignmentFilterId;
            }
            text += GetAssignmentFilter(filterId);
        }
        return text;
    }

    private string GetAssignmentFilter(string? filterId)
    {
        if (filterId == null || filterId == "00000000-0000-0000-0000-000000000000") return string.Empty;
        return " (Filter: " + _graphData.GetGroupAssignmentFilterName(filterId) + ")";
    }
    private static string GetAppliesToName(PolicyScope? scope)
    {
        if (scope == null) return string.Empty;

        return scope switch
        {
            PolicyScope.None => "None",
            PolicyScope.All => "All",
            PolicyScope.Selected => "Some",
            _ => nameof(scope),
        };
    }

    private static string GetEnrollmentRestrictionPlatformTypeName(EnrollmentRestrictionPlatformType? platformType)
    {
        if (platformType == null) return string.Empty;

        return platformType switch
        {
            EnrollmentRestrictionPlatformType.Android => Labels.PlatformAndroid,
            EnrollmentRestrictionPlatformType.AndroidForWork => Labels.PlatformAndroidForWork,
            EnrollmentRestrictionPlatformType.Windows => Labels.PlatformWindows,
            EnrollmentRestrictionPlatformType.Ios => Labels.PlatformIos,
            EnrollmentRestrictionPlatformType.Mac => Labels.PlatformMacOs,
            _ => nameof(platformType),
        };
    }

    private static string GetIsBlockedString(bool? value)
    {
        if (value == null) return string.Empty;
        return (bool)value ? "Blocked" : "Allowed";
    }
}
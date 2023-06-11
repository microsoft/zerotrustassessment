using Syncfusion.XlsIO;
using ZeroTrustAssessment.DocumentGenerator.Graph;
using ZeroTrustAssessment.DocumentGenerator.Infrastructure;
using ZeroTrustAssessment.DocumentGenerator.ViewModels;

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
        DeviceCompliancePolicies();
    }

    private void MdmWindowsEnrollment()
    {
        var table = new ExcelTable(_sheet, "Table_WindowsEnrollment");

        if (_graphData.MobilityManagementPolicies == null)
        {
            table.ShowNoDataMessage();
            return;
        }

        var rowCount = _graphData.MobilityManagementPolicies.Count;
        table.InitializeRows(rowCount);
        foreach (var policy in _graphData.MobilityManagementPolicies.OrderByDescending(x => x.AppliesTo).ThenBy(x => x.DisplayName))
        {
            var groupName = policy.AppliesTo == PolicyScope.Selected && policy.IncludedGroups != null ?
                string.Join(", ", policy.IncludedGroups.Select(x => x.DisplayName)) : "N/A";

            table.AddColumn("MDM");
            table.AddColumn(policy.DisplayName, 5);
            table.AddColumn(GetAppliesToName(policy.AppliesTo), 2);
            table.AddColumn(groupName);
            table.NextRow();
        }
    }

    private void DeviceEnrollmentConfiguration()
    {
        var platformRestrictions = _graphData.DeviceEnrollmentConfigurations?
            .Where(x => x.DeviceEnrollmentConfigurationType == DeviceEnrollmentConfigurationType.SinglePlatformRestriction)
            .OrderByDescending(x => x.Priority).ThenBy(x => x.DisplayName);

        var rowCount = (platformRestrictions?.Count() ?? 0) + 5;

        var startColumn = _sheet.Range["Table_EnrollmentDevicePlatformRestrictions"].Column;
        var startRow = _sheet.Range["Table_EnrollmentDevicePlatformRestrictions"].Row;

        var row = startRow;
        _sheet.InsertRow(startRow, rowCount);
        var views = EnrollmentRestrictionView.GetViews(_graphData);
        foreach (var view in views)
        {
            _sheet.SetText(row, startColumn, view.Platform);
            _sheet.SetValue(row, startColumn + 3, $"{view.Priority}");
            _sheet.SetText(row, startColumn + 4, view.DisplayName);

            _sheet.SetText(row, startColumn + 8, view.PlatformBlocked);
            _sheet.SetText(row, startColumn + 9, view.OsMinimumVersion);
            _sheet.SetText(row, startColumn + 10, view.OsMaximumVersion);
            _sheet.SetText(row, startColumn + 11, view.PersonalDeviceEnrollmentBlocked);
            _sheet.SetText(row, startColumn + 13, view.BlockedManufacturers);
            _sheet.SetText(row, startColumn + 15, view.Scopes);
            _sheet.SetText(row, startColumn + 16, view.Assignments);
            row++;
        }
        // if (platformRestrictions != null)
        // {
        //     var restrictions = new Dictionary<string, DeviceEnrollmentPlatformRestrictionConfiguration>();
        //     foreach (var config in platformRestrictions)
        //     {
        //         if (config is DeviceEnrollmentPlatformRestrictionConfiguration restriction) //First iterate and create list to make it easier to sort
        //         {
        //             var sortKey = restriction.DisplayName + GetEnrollmentRestrictionPlatformTypeName(restriction.PlatformType) + restriction.Id;
        //             restrictions.Add(sortKey, restriction);
        //         }
        //     }
        //     foreach (var item in restrictions.OrderBy(x => x.Key))
        //     {
        //         var restriction = item.Value;
        //         var platform = GetEnrollmentRestrictionPlatformTypeName(restriction.PlatformType);
        //         var priority = restriction.Priority;
        //         var displayName = restriction.DisplayName;
        //         var scopes = _graphData.GetScopesString(restriction.RoleScopeTagIds);
        //         var assignments = _graphData.GetGroupAssignmentTargetText(restriction.Assignments);

        //         AddDeviceEnrollmentRow(row, startColumn, platform, priority, displayName, restriction.PlatformRestriction, scopes, assignments);

        //         row++;
        //     }
        // }
        // var defaultPlatformRestrictions = _graphData.DeviceEnrollmentConfigurations?
        //     .Where(x => x.DeviceEnrollmentConfigurationType == DeviceEnrollmentConfigurationType.PlatformRestrictions).FirstOrDefault();
        // if (defaultPlatformRestrictions != null && defaultPlatformRestrictions is DeviceEnrollmentPlatformRestrictionsConfiguration defaultRestriction)
        // {

        //     var platform = string.Empty;
        //     var priority = defaultRestriction.Priority;
        //     var displayName = "Default";
        //     var scopes = _graphData.GetScopesString(defaultRestriction.RoleScopeTagIds);
        //     var assignments = "All users and all devices";

        //     AddDeviceEnrollmentRow(row, startColumn, Labels.PlatformAndroidForWork, priority, displayName, defaultRestriction.AndroidForWorkRestriction, scopes, assignments); row++;
        //     AddDeviceEnrollmentRow(row, startColumn, Labels.PlatformAndroid, priority, displayName, defaultRestriction.AndroidRestriction, scopes, assignments); row++;
        //     AddDeviceEnrollmentRow(row, startColumn, Labels.PlatformIos, priority, displayName, defaultRestriction.IosRestriction, scopes, assignments); row++;
        //     AddDeviceEnrollmentRow(row, startColumn, Labels.PlatformMacOs, priority, displayName, defaultRestriction.MacOSRestriction, scopes, assignments); row++;
        //     AddDeviceEnrollmentRow(row, startColumn, Labels.PlatformWindows, priority, displayName, defaultRestriction.WindowsRestriction, scopes, assignments); row++;
        // }

    }
    // private void AddDeviceEnrollmentRow(int row, int startColumn, string platform, int? priority, string? displayName, DeviceEnrollmentPlatformRestriction? platformRestriction, string scopes, string assignments)
    // {
    //     _sheet.SetText(row, startColumn, platform);
    //     _sheet.SetValue(row, startColumn + 3, $"{priority}");
    //     _sheet.SetText(row, startColumn + 4, displayName);

    //     if (platformRestriction != null)
    //     {
    //         _sheet.SetText(row, startColumn + 8, GetIsBlockedString(platformRestriction.PlatformBlocked));
    //         _sheet.SetText(row, startColumn + 9, GetString(platformRestriction.OsMinimumVersion));
    //         _sheet.SetText(row, startColumn + 10, GetString(platformRestriction.OsMaximumVersion));
    //         _sheet.SetText(row, startColumn + 11, GetIsBlockedString(platformRestriction.PersonalDeviceEnrollmentBlocked));
    //         _sheet.SetText(row, startColumn + 13, platformRestriction.BlockedManufacturers?.Count > 0 ? string.Join(", ", platformRestriction.BlockedManufacturers) : string.Empty);
    //         _sheet.SetText(row, startColumn + 15, scopes);
    //         _sheet.SetText(row, startColumn + 16, assignments);
    //     }
    // }


    private void DeviceCompliancePolicies()
    {
        //TODO Add linux
        var compliancePolicies = _graphData.DeviceCompliancePolicies;

        if (compliancePolicies == null || compliancePolicies.Count() == 0)
        {
            SetValue("Table_DeviceCompliancePolicies", "Not configured");
        }

        var rowCount = compliancePolicies?.Count() ?? 0;

        var startColumn = _sheet.Range["Table_DeviceCompliancePolicies"].Column;
        var startRow = _sheet.Range["Table_DeviceCompliancePolicies"].Row;

        var row = startRow;
        _sheet.InsertRow(startRow, rowCount);

        if (compliancePolicies != null)
        {
            var view = new List<DeviceCompliancePolicyView>();

            foreach (var policy in compliancePolicies)
            {
                view.Add(new DeviceCompliancePolicyView(_graphData, policy));
            }

            foreach (var item in view)
            {
                _sheet.SetText(row, startColumn, item.Platform);
                _sheet.SetText(row, startColumn + 3, item.DisplayName);

                _sheet.SetText(row, startColumn + 8, item.OsMinimumVersion);
                _sheet.SetText(row, startColumn + 9, item.OsMaximumVersion);
                _sheet.SetText(row, startColumn + 10, item.MobileOsMinimumVersion);
                _sheet.SetText(row, startColumn + 11, item.MobileOsMaximumVersion);
                _sheet.SetText(row, startColumn + 12, item.ValidOperatingSystemBuildRanges);
                _sheet.SetText(row, startColumn + 13, item.PasswordRequired);
                _sheet.SetText(row, startColumn + 14, item.PasswordBlockSimple);
                _sheet.SetText(row, startColumn + 15, item.PasswordRequiredType);
                _sheet.SetText(row, startColumn + 16, item.PasswordMinimumLength);
                _sheet.SetText(row, startColumn + 17, item.PasswordMinutesOfInactivityBeforeLock);
                _sheet.SetText(row, startColumn + 18, item.PasswordExpirationDays);
                _sheet.SetText(row, startColumn + 19, item.PasswordPreviousPasswordBlockCount);
                _sheet.SetText(row, startColumn + 20, item.PasswordRequiredToUnlockFromIdle);
                _sheet.SetText(row, startColumn + 21, item.StorageRequireEncryption);
                _sheet.SetText(row, startColumn + 22, item.ActiveFirewallRequired);
                _sheet.SetText(row, startColumn + 23, item.TpmRequired);
                _sheet.SetText(row, startColumn + 24, item.AntivirusRequired);
                _sheet.SetText(row, startColumn + 25, item.AntiSpywareRequired);
                _sheet.SetText(row, startColumn + 26, item.DefenderEnabled);
                _sheet.SetText(row, startColumn + 27, item.DefenderVersion);

                _sheet.SetText(row, startColumn + 28, item.Scopes);
                _sheet.SetText(row, startColumn + 29, item.Assignments);

                row++;
            }
        }
    }


    public static string GetString(string? value)
    {
        return value ?? string.Empty;
    }

    public static string GetAppliesToName(PolicyScope? scope)
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
    public static string GetIsBlockedString(bool? value)
    {
        if (value == null) return string.Empty;
        return (bool)value ? "Blocked" : "Allowed";
    }
}
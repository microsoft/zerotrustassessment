using Syncfusion.XlsIO;
using ZeroTrustAssessment.DocumentGenerator.Graph;
using ZeroTrustAssessment.DocumentGenerator.Infrastructure;
using ZeroTrustAssessment.DocumentGenerator.ViewModels;

namespace ZeroTrustAssessment.DocumentGenerator.Sheets;

public class SheetConfigDevice : SheetBase
{
    public SheetConfigDevice(IWorkbook workbook, ZtSheets sheet, GraphData graphData) : base(workbook, sheet, graphData)
    {
    }

    public void Generate()
    {
        MdmWindowsEnrollment();
        DeviceEnrollmentConfiguration();
        DeviceCompliancePolicies();
        AppProtectionPolicies();
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
                string.Join(", ", policy.IncludedGroups.Select(x => x.DisplayName)) : Labels.NotApplicableString;

            table.AddColumn("MDM");
            table.AddColumn(policy.DisplayName, 5);
            table.AddColumn(GetAppliesToName(policy.AppliesTo), 2);
            table.AddColumn(groupName);
            table.NextRow();
        }
    }

    private void DeviceEnrollmentConfiguration()
    {
        var views = EnrollmentRestrictionView.GetViews(_graphData).OrderByDescending((x => x.Priority)).ThenBy(x => x.Platform).ThenBy(x => x.DisplayName);
        var table = new ExcelTable(_sheet, "Table_EnrollmentDevicePlatformRestrictions");
        table.InitializeRows(views.Count());

        foreach (var view in views)
        {
            table.AddColumn(view.Platform, 3);
            table.AddColumn($"{view.Priority}");
            table.AddColumn(view.DisplayName, 4);
            table.AddColumn(view.PlatformBlocked);
            table.AddColumn(view.OsMinimumVersion);
            table.AddColumn(view.OsMaximumVersion);
            table.AddColumn(view.PersonalDeviceEnrollmentBlocked, 2);
            table.AddColumn(view.BlockedManufacturers, 2);
            table.AddColumn(view.Scopes);
            table.AddColumn(view.Assignments);
            table.NextRow();
        }
    }

    private void DeviceCompliancePolicies()
    {
        var views = new DeviceCompliancePolicyViews(_graphData).GetViews().OrderBy(x => x.Platform).ThenBy(x => x.PolicyType).ThenBy(x => x.DisplayName);

        var table = new ExcelTable(_sheet, "Table_DeviceCompliancePolicies");
        if (views.Count() == 0)
        {
            table.ShowNoDataMessage();
        }
        else
        {
            table.InitializeRows(views.Count());

            foreach (var item in views)
            {
                table.AddColumn(item.Platform, 3);
                table.AddColumn(item.DisplayName, 5);
                table.AddColumn(item.DefenderForEndPoint);
                table.AddColumn(item.OsMinimumVersion);
                table.AddColumn(item.OsMaximumVersion);
                table.AddColumn(item.PasswordRequired);
                table.AddColumn(item.PasswordMinimumLength);
                table.AddColumn(item.PasswordRequiredType, 2);
                table.AddColumn(item.PasswordExpirationDays);
                table.AddColumn(item.PasswordPreviousPasswordBlockCount);
                table.AddColumn(item.PasswordMinutesOfInactivityBeforeLock);
                table.AddColumn(item.StorageRequireEncryption);
                table.AddColumn(item.SecurityBlockJailbrokenDevices);
                table.AddColumn(item.DeviceThreatProtectionRequiredSecurityLevel);
                table.AddColumn(item.ActiveFirewallRequired);
                table.AddColumn(item.NoncomplianceActionPushNotification, 2);
                table.AddColumn(item.NoncomplianceActionNotification, 2);
                table.AddColumn(item.NoncomplianceActionRemoteLock, 2);
                table.AddColumn(item.NoncomplianceActionBlock, 2);
                table.AddColumn(item.NoncomplianceActionRetire, 2);
                table.AddColumn(item.Scopes, 2);
                table.AddColumn(item.IncludedGroups, 2);
                table.AddColumn(item.ExcludedGroups, 2);
                table.NextRow();

                // Move to Windows table
                // table.AddColumn(item.MobileOsMinimumVersion);
                // table.AddColumn(item.MobileOsMaximumVersion);
                // table.AddColumn(item.ValidOperatingSystemBuildRanges);
                // table.AddColumn(item.PasswordBlockSimple);               
                // table.AddColumn(item.PasswordRequiredToUnlockFromIdle);                
                // table.AddColumn(item.TpmRequired);
                // table.AddColumn(item.AntivirusRequired);
                // table.AddColumn(item.AntiSpywareRequired);               
                // table.AddColumn(item.DefenderVersion);
            }
        }
    }

    private void AppProtectionPolicies()
    {
        var views = new AppProtectionPolicyViews(_graphData).GetViews().OrderBy(x => x.Platform).ThenBy(x => x.DisplayName);

        var table = new ExcelTable(_sheet, "Table_AppProtectionPolicies");
        if (views.Count() == 0)
        {
            table.ShowNoDataMessage();
        }
        else
        {
            table.InitializeRows(views.Count());

            foreach (var item in views)
            {
                table.AddColumn(item.Platform, 3);
                table.AddColumn(item.DisplayName, 5);
                table.AddColumn(item.PublicApps, 2);
                table.AddColumn(item.CustomApps, 2);
                table.AddColumn(item.PreventBackups, 1);
                table.AddColumn(item.SendOrgDataToOtherApps, 2);
                table.AddColumn(item.AppsToExempt, 1);
                table.AddColumn(item.SaveCopiesOfOrgData, 1);
                table.AddColumn(item.AllowUserToSaveCopiesToSelectedServices, 1);
                table.AddColumn(item.TransferTelecommunicationDataTo, 1);
                table.AddColumn(item.ReceiveDataFromOtherApps, 1);
                table.AddColumn(item.OpenDataIntoOrgDocuments, 1);
                table.AddColumn(item.AllowUsersToOpenDataFromSelectedServices, 1);
                table.AddColumn(item.RestrictCutCopyAndPasteBetweenOtherApps, 1);
                table.AddColumn(item.CutAndCopyCharacterLimitForAnyApp, 1);
                table.AddColumn(item.EncryptOrgData, 1);
                table.AddColumn(item.SyncPolicyManagedAppDataWithNativeAppsOrAddIns, 1);
                table.AddColumn(item.PrintingOrgData, 1);
                table.AddColumn(item.RestrictWebContentTransferWithOtherApps, 1);
                table.AddColumn(item.OrgDataNotifications, 1);
                table.AddColumn(item.MaxPinAttemptsAction, 2);
                table.AddColumn(item.OfflineGracePeriodBlockAccessMin, 1);
                table.AddColumn(item.OfflineGracePeriodWipeDataDays, 1);
                table.AddColumn(item.DisabedAccount, 1);
                table.AddColumn(item.MinAppVersionAction, 1);
                table.AddColumn(item.RootedJailbrokenDevices, 1);
                table.AddColumn(item.PrimaryMTDService, 1);
                table.AddColumn(item.MaxAllowedDeviceThreatLevel, 1);
                table.AddColumn(item.MinOSVersion, 1);
                table.AddColumn(item.MaxOSVersion, 1);
                table.AddColumn(item.Scopes, 2);
                table.AddColumn(item.IncludedGroups, 2);
                table.AddColumn(item.ExcludedGroups, 2);
                table.NextRow();

                // Move to Windows table
                // table.AddColumn(item.MobileOsMinimumVersion);
                // table.AddColumn(item.MobileOsMaximumVersion);
                // table.AddColumn(item.ValidOperatingSystemBuildRanges);
                // table.AddColumn(item.PasswordBlockSimple);               
                // table.AddColumn(item.PasswordRequiredToUnlockFromIdle);                
                // table.AddColumn(item.TpmRequired);
                // table.AddColumn(item.AntivirusRequired);
                // table.AddColumn(item.AntiSpywareRequired);               
                // table.AddColumn(item.DefenderVersion);
            }
        }
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
}
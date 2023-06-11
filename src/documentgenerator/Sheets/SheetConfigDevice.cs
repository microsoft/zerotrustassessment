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
        var views = EnrollmentRestrictionView.GetViews(_graphData).OrderBy(x => x.Platform).ThenBy(x => x.DisplayName);
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
        var views = new DeviceCompliancePolicyViews(_graphData).GetViews();

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
                table.AddColumn(item.OsMinimumVersion);
                table.AddColumn(item.OsMaximumVersion);
                table.AddColumn(item.MobileOsMinimumVersion);
                table.AddColumn(item.MobileOsMaximumVersion);
                table.AddColumn(item.ValidOperatingSystemBuildRanges);
                table.AddColumn(item.PasswordRequired);
                table.AddColumn(item.PasswordBlockSimple);
                table.AddColumn(item.PasswordRequiredType);
                table.AddColumn(item.PasswordMinimumLength);
                table.AddColumn(item.PasswordMinutesOfInactivityBeforeLock);
                table.AddColumn(item.PasswordExpirationDays);
                table.AddColumn(item.PasswordPreviousPasswordBlockCount);
                table.AddColumn(item.PasswordRequiredToUnlockFromIdle);
                table.AddColumn(item.StorageRequireEncryption);
                table.AddColumn(item.ActiveFirewallRequired);
                table.AddColumn(item.TpmRequired);
                table.AddColumn(item.AntivirusRequired);
                table.AddColumn(item.AntiSpywareRequired);
                table.AddColumn(item.DefenderEnabled);
                table.AddColumn(item.DefenderVersion);

                table.AddColumn(item.Scopes);
                table.AddColumn(item.Assignments);
                table.NextRow();
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
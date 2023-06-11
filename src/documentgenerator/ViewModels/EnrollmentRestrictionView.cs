using ZeroTrustAssessment.DocumentGenerator.Graph;
using ZeroTrustAssessment.DocumentGenerator.Infrastructure;
using ZeroTrustAssessment.DocumentGenerator.Sheets;

namespace ZeroTrustAssessment.DocumentGenerator.ViewModels;
public class EnrollmentRestrictionView
{
    public string? DisplayName { get; set; }
    public string? Platform { get; set; }
    public int? Priority { get; set; }
    public string? Scopes { get; set; }
    public string? Assignments { get; set; }
    public string? PlatformBlocked { get; set; }
    public string? OsMinimumVersion { get; set; }
    public string? OsMaximumVersion { get; set; }
    public string? PersonalDeviceEnrollmentBlocked { get; set; }
    public string? BlockedManufacturers { get; set; }

    public static List<EnrollmentRestrictionView> GetViews(GraphData graphData)
    {
        var platformRestrictions = graphData.DeviceEnrollmentConfigurations?
            .Where(x => x.DeviceEnrollmentConfigurationType == DeviceEnrollmentConfigurationType.SinglePlatformRestriction)
            .OrderByDescending(x => x.Priority).ThenBy(x => x.DisplayName);

        var views = new List<EnrollmentRestrictionView>();

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
                var view = new EnrollmentRestrictionView(); views.Add(view);
                var restriction = item.Value;
                view.Platform = GetEnrollmentRestrictionPlatformTypeName(restriction.PlatformType);
                view.Priority = restriction.Priority;
                view.DisplayName = restriction.DisplayName;
                view.Scopes = graphData.GetScopesString(restriction.RoleScopeTagIds);
                view.Assignments = graphData.GetGroupAssignmentTargetText(restriction.Assignments);
                SetPlatformRestriction(view, restriction.PlatformRestriction);
            }
        }
        var defaultPlatformRestrictions = graphData.DeviceEnrollmentConfigurations?
            .Where(x => x.DeviceEnrollmentConfigurationType == DeviceEnrollmentConfigurationType.PlatformRestrictions).FirstOrDefault();
        if (defaultPlatformRestrictions != null && defaultPlatformRestrictions is DeviceEnrollmentPlatformRestrictionsConfiguration defaultRestriction)
        {
            var priority = defaultRestriction.Priority;
            var scopes = graphData.GetScopesString(defaultRestriction.RoleScopeTagIds);

            views.Add(GetDefaultRestriction(Labels.PlatformAndroidForWork, scopes, priority, defaultRestriction.AndroidForWorkRestriction));

            views.Add(GetDefaultRestriction(Labels.PlatformAndroid, scopes, priority, defaultRestriction.AndroidRestriction));
            views.Add(GetDefaultRestriction(Labels.PlatformIos, scopes, priority, defaultRestriction.IosRestriction));
            views.Add(GetDefaultRestriction(Labels.PlatformMacOs, scopes, priority, defaultRestriction.MacOSRestriction));
            views.Add(GetDefaultRestriction(Labels.PlatformWindows, scopes, priority, defaultRestriction.WindowsRestriction));
        }

        return views;
    }

    private static EnrollmentRestrictionView GetDefaultRestriction(string platform, string scopes, int? priority, DeviceEnrollmentPlatformRestriction? platformRestriction)
    {
        var view = new EnrollmentRestrictionView
        {
            Platform = platform,
            Priority = priority,
            DisplayName = "Default",
            Assignments = "All users and all devices",
            Scopes = scopes
        };
        SetPlatformRestriction(view, platformRestriction);
        return view;
    }

    private static void SetPlatformRestriction(EnrollmentRestrictionView view, DeviceEnrollmentPlatformRestriction? platformRestriction)
    {
        if (platformRestriction != null)
        {
            view.PlatformBlocked = SheetConfigDevice.GetIsBlockedString(platformRestriction.PlatformBlocked);
            view.OsMinimumVersion = SheetConfigDevice.GetString(platformRestriction.OsMinimumVersion);
            view.OsMaximumVersion = SheetConfigDevice.GetString(platformRestriction.OsMaximumVersion);
            view.PersonalDeviceEnrollmentBlocked = SheetConfigDevice.GetIsBlockedString(platformRestriction.PersonalDeviceEnrollmentBlocked);
            view.BlockedManufacturers = platformRestriction.BlockedManufacturers?.Count > 0 ? string.Join(", ", platformRestriction.BlockedManufacturers) : string.Empty;
        }
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
}